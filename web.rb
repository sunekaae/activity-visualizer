require 'sinatra'
require 'sinatra-initializers'
require 'sinatra/redis'
require 'resque/status_server'
require 'haml'
require 'json'
require 'rest_client'
require 'thingiverse'
require 'nike_v2'
require_relative 'src/nikeapi'
require_relative 'src/open_scad_template'

# jobs for resque-status
require_relative 'src/nikeapi_job'

# http://stackoverflow.com/questions/7847536/sinatra-in-facebook-iframe
disable :protection

configure do
  require 'redis'
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  Resque::Plugins::Status::Hash.expire_in = (5 * 60) # value is seconds
end


get '/' do
  accessToken = params["accesstoken"]
  haml :index, :locals => {:accessToken => accessToken}
end

# this is not working any longer, must pass in the thingiverse token
# or rewrite the NikeAPIJob method to skip the TV stuff
get '/nikejob' do
  nike_access_token = params["nike_access_token"]

  unless nike_access_token.nil? || nike_access_token.empty?
    job_id = NikeAPIJob.create(:nike_access_token => nike_access_token)

    # return the job_id hash to some ajax-ish stuff, which can poll
    # the status hash for it's state. 
    # when the api access is complete, redirect to handle the Thingiverse
    # calls and link to customizer.
    
    redirect "/status?job_id=#{job_id}"
  end

end


# can poll this endpoint to get the job status.
get '/status' do
  # expects a job id hash
  job_id = params['job_id']
  unless job_id.nil? || job_id.empty?
    status = Resque::Plugins::Status::Hash.get(job_id)

    unless status.nil?
      jobStatus = status.status

      # if the status is complete, we can get the data from the attached keys
      # see NikeAPIJob for details on the key names.
      if jobStatus == 'completed'

        # call the processed endpoint
        # this is a hack:
        redirect "/processed?thing_id=#{status['thing_id']}&thing_name=#{status['thing_name']}&destination_url=#{status['destination_url']}"
      end

      # wow. this is ugly, even for me.
      response = '<html><head><meta http-equiv="refresh" content="5"></head><body>'
      response += jobStatus
      response += '</body></html>'

      response
    end
  end
end

# TODO: make this a POST or otherwise pass the parameters in a better way
get '/processed' do
  thing_id = params.has_key?('thing_id') ? params['thing_id'] : 'thing id not specified'
  thing_name = params.has_key?('thing_name') ? params['thing_name'] : 'thing name not specified'
  destination_url = params.has_key?('destination_url') ? params['destination_url'] : ''

  #TODO: have some error checking
  response = {
      :thing_id => thing_id,
      :thing_name => thing_name,
      :destination_url => destination_url
  }

  haml :processed, :locals => response
end


get '/app' do
  "<h2>/app text could go here.</h2>"
end

get '/info' do
  "<h2>/info text could go here.</h2>"
end

get '/callback' do
  code = params["code"]
  puts "code: #{code}"

  # Thingiverse client id / secret are defined as environment variables
  tv = Thingiverse::Connection.new(ENV['TV_ID'], ENV['TV_SECRET'], code)
  redirect "./redirected?access_token=#{tv.access_token}"
end

get '/redirected' do
  access_token = params["access_token"]
  nike_access_token = params["nike_access_token"]
  start_date = params["start_date"]
  end_date = params["end_date"]

  if access_token.nil? || access_token.empty? then
    return "Missing a Thingiverse ?access_token=your-access-token"
  end
  if nike_access_token.nil? || nike_access_token.empty? then
    return haml :login, :locals => {:access_token => access_token}
  end
  if (nike_access_token.size < 25 || nike_access_token.size > 35) then
    return "Looks like the nike access token is not correct. (input: #{nike_access_token})"
    # note, I initially thought the token was always 32 chars, but I've seen one of 31 chars as well.
  end

  # have both a Thingiverse and Nike access token.
  # can proceed now:
  # - get nike data
  # - pre-process data
  # - customize scad template
  # - create new Thing and upload scad file
  # - redirect to new Thing.

  # if start_date and end_date are provided, then
  # calculate the number of days between them and use
  # the overloaded method of ActivityGetter
  puts "about to do date stuff"
  daysDelta = nil

  # NOTE: something is odd with the dates and Nike service
  # subtracting one here (and adding to the delta) is a (sloppy) workaround
  if start_date.nil? || start_date.empty? || (Date.parse(start_date) rescue nil).nil?
    start_date = "2013-03-25"
  end
  startDate = Date.parse(start_date) - 1

  if end_date.nil? || end_date.empty? || (Date.parse(end_date) rescue nil).nil?
    end_date = (startDate+7).to_s
  end
  endDate = Date.parse(end_date) - 1

  dateDelta = endDate - startDate
  daysDelta = dateDelta.to_i + 1

  # this is the asynchronous flow:
  job_id = NikeAPIJob.create(:thingiverse_access_token => access_token,
                             :nike_access_token => nike_access_token,
                             :daysDelta => daysDelta,
                             :startDate => startDate,
                             :endDate => endDate
  )

  # return the job_id hash to some ajax-ish stuff, which can poll
  # the status hash for it's state.
  # when the api access is complete, redirect to handle the Thingiverse
  # calls and link to customizer.

  unless job_id.nil?
    redirect "/status?job_id=#{job_id}"
  end

  "I've made a huge mistake. Try again"
end

get '/iframe' do
  # this is a test screen which is not in use by this app.
  code = params["code"]
  puts "code: #{code}"

  # Thingiverse client id / secret are defined as environment variables
  tv = Thingiverse::Connection.new(ENV['TV_ID'], ENV['TV_SECRET'], code)

  haml :iframeTest, :locals => {:tv => tv}
end


# this is just saved for posterity
# should likely be removed when we feel confident about the Resque (asynchronous) flow
def synchronousWorkflow(token, nike_token, daysDelta, startDate, endDate)
  puts "getting nike data"
  activity_getter = ActivityGetter.new(nike_token,
                                       daysDelta,
                                       startDate.to_s,
                                       endDate.to_s)
  activity_getter.get_week_of_data_as_array_of_array

  dailyActivity = activity_getter.array_of_array.inspect
  dailyTotals = activity_getter.total_per_day.inspect

  puts "starting scad logic"
  # generate the template data with the output of ActivityGetter
  # look at the Template class for additional parameters
  # eg. name, goalTarget, etc.
  template = OpenScadTemplate.new(dailyActivity,
                                  dailyTotals,
                                  activity_getter.goal,
                                  activity_getter.start_date,
                                  activity_getter.end_date,
                                  activity_getter.totalFuel.to_s + " Fuel") # using the Name field for this value.
  outputSCAD = template.customizeTemplate

  thingiverse_filename = "my_nike_activity.scad"

  puts "about to create thing"
  tv = Thingiverse::Connection.new
  tv.access_token = token
  thing = tv.things.create(:name => 'Nike+ Activity Thing',
                           :license => 'cc-nc-sa',
                           :category => 'Sports & Outdoors',
                           :description => 'My Nike+ FuelBand activity.',
                           :tags => ["hackathon", "nike+", "customizer", "fuelband"],
                           :is_wip => true,
                           :ancestors => ['71126'])
  destination_url = "http://www.thingiverse.com/apps/customizer/run?thing_id=#{thing.id}"

  puts "about to upload file"
  my_file = thing.upload_string(outputSCAD, thingiverse_filename)

  response = {
      :thing_id => thing.id,
      :thing_name => thing.name,
      :destination_url => destination_url
  }
end