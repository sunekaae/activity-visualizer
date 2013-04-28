require_relative '../src/open_scad_template.rb'
require_relative '../src/nikeapi'

#template = Template.new([1],[2])
#puts template.customizeTemplate

# default is a week of data:
test_access_token = ''
activity_getter = ActivityGetter.new(test_access_token)

# get a month of data:
#activity_getter = ActivityGetter.new(test_access_token, 31, "2013-03-01", "2013-03-31")

# get data (misnamed method name)

#format = 'values' # values or points (default)
format = 'points' # values or points (default)

activity_getter.get_week_of_data_as_array_of_array(format)

dailyActivity = activity_getter.array_of_array.inspect
dailyTotals = activity_getter.total_per_day.inspect

template = OpenScadTemplate.new(
  dailyActivity,
  dailyTotals,
  activity_getter.goal,
  "",
  "",
  activity_getter.totalFuel.to_s + " Fuel")

outputSCAD = template.customizeTemplate(format)

path_and_filename = File.join(File.dirname(__FILE__), '../openscad/temp-output.scad')
File.open(path_and_filename, 'w') {|f| f.write(outputSCAD) }



