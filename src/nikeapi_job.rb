require 'resque/job_with_status' # in rails you would probably do this in an initializer

require 'thingiverse'
require_relative 'nikeapi'
require_relative 'open_scad_template'

# queries NikeAPI with provided parameters

class NikeAPIJob
  include Resque::Plugins::Status

  def perform
    # TODO: handle all parameters which may be sent to ActivityGetter
    nike_token = options.has_key?('nike_access_token') ? options['nike_access_token'] : nil
    thingiverse_token = options.has_key?('thingiverse_access_token') ? options['thingiverse_access_token'] : nil

    # parse other options, or set defaults if options are not present:
    daysDelta = options.has_key?('daysDelta') ? options['daysDelta'] : 7
    startDate = options.has_key?('startDate') ? options['startDate'] : Date.parse('2013-03-25')
    endDate =   options.has_key?('endDate') ? options['endDate']     : startDate + daysDelta

    unless nike_token.nil? || thingiverse_token.nil?
      # all this takes a while...

      puts 'getting nike data'
      puts 'requesting activity list'
      activity_getter = ActivityGetter.new(nike_token,
                                           daysDelta,
                                           startDate.to_s,
                                           endDate.to_s)

      puts 'requesting activity details (many calls)'
      activity_getter.get_week_of_data_as_array_of_array

      # store the relevant parameters for clarity later
      dailyActivity = activity_getter.array_of_array.inspect
      dailyTotals =   activity_getter.total_per_day.inspect
      goal =          activity_getter.goal
      totalFuel =     activity_getter.totalFuel.to_s


      puts 'starting scad logic'
      # generate the template data with the output of ActivityGetter
      # look at the Template class for additional parameters
      # eg. name, goalTarget, etc.
      template = OpenScadTemplate.new(dailyActivity,
                                      dailyTotals,
                                      goal,
                                      startDate.to_s,
                                      endDate.to_s,
                                      totalFuel.to_s + ' Fuel') # using the Name field for this value.
      outputSCAD = template.customizeTemplate

      thingiverse_filename = 'my_nike_activity.scad'

      puts 'about to create thing'
      tv = Thingiverse::Connection.new
      tv.access_token = thingiverse_token
      thing = tv.things.create(:name => 'Nike+ Activity Thing',
                               :license => 'cc-nc-sa',
                               :category => 'Sports & Outdoors',
                               :description => 'My Nike+ FuelBand activity.',
                               :tags => %w(hackathon nike+ customizer fuelband),
                               :is_wip => true,
                               :ancestors => %w(71126))
      destination_url = "http://www.thingiverse.com/apps/customizer/run?thing_id=#{thing.id}"

      puts 'about to upload file'
      my_file = thing.upload(outputSCAD, thingiverse_filename)

      puts "all finished, sent: #{my_file}"
      # build a response object (currently, this can be passed directly to the haml for the upload result page)
      response = {
        :thing_id => thing.id,
        :thing_name => thing.name,
        :destination_url => destination_url
      }
    end

    # unsure if this is inefficient
    completed(response)
  end
end
