require 'nike_v2'

class ActivityGetter
  attr_accessor :accessToken
  attr_accessor :array_of_array
  attr_accessor :total_per_day
  attr_accessor :start_date
  attr_accessor :end_date

  attr_accessor :goal
  attr_accessor :totalFuel

  def initialize in_accessToken, in_count = 7, in_start_date = "2013-03-25", in_end_date = "2013-03-31"
    @accessToken = in_accessToken
    @count = in_count
    @start_date = in_start_date
    @end_date = in_end_date
    @array_of_array = Array.new # fuel per day
    @total_per_day = Array.new

  end

  def get_week_of_data_as_array_of_array (_format = "points")
    # Initialize a person
    person = NikeV2::Person.new(:access_token => @accessToken)
    
    # Fetch persons summary
    @goal = person.summary.fuelband["DAILYGOALTARGETVALUE"]


    # Fetch a persons activities
    person.activities(:count => @count, :start_date => @start_date, :end_date => @end_date).each do |activity|
      # describe the activity start date
      puts activity.started_at
      activity.load_data

      # for each metric type:
      if activity.device_type == "FUELBAND"
        puts 'found FuelBand type activity'

        # NOTE: this seems kind of slow, but it does aggregate the data series
        #
        #only want fuel, but there seem to be some activities with
        #multiple fuel type metric items, sum them together
        fuelMetrics = activity.metrics.find_all{|i| i.type == 'FUEL'}

        if fuelMetrics.count > 0
          # sum the parallel arrays
          item = fuelMetrics.map{|m| m.values}.transpose.map {|x| x.reduce(:+)}

          #puts item.inspect
          #puts item.type
          #puts item.total
          item_total = item.inject(:+)

          @total_per_day.push(item_total.to_i)


          #presume that there are 1440 data points in the array
          puts "item contains " + item.count.to_s + " values"

          if _format == 'points'
            downsampled = downsample(item, 15) # provides 96 data points

            # smooth the data 
            smoothed = []
            downsampled.each_cons(4) {|a| 
              total = a.inject(:+)
              len = a.length

              mean = total.to_f/len
              smoothed.push(mean)
            }

            # make tuples of the data for the polygon option
            tuples = []
            smoothed.each_index {
              |n| tuples.push([n, smoothed[n]])
            }

            tuples.unshift([0, -0.01])
            tuples.push([smoothed.count, -0.01])

            @array_of_array.push(tuples)
          else
            downsampled = downsample(item, 60) # provides 24 data points
            @array_of_array.push(downsampled)
          end
        end
      end

      @totalFuel = total_per_day.inject(:+)

    end
  end

  def downsample(_item, _binWidth = 15)
      downsampled = []
      _item.each_slice(_binWidth) do |chunk|
        downsampled.push(chunk.inject(:+).to_i)
      end
      downsampled
  end
end

# manual test
if (false) then
  test_access_token = '37c01c00a81430ede40bc8bc908ab544';
  activity_getter = ActivityGetter.new(test_access_token)
  activity_getter.get_week_of_data_as_array_of_array
  puts activity_getter.array_of_array.inspect
  puts activity_getter.total_per_day.inspect
end

