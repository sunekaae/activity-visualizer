# open the openscad template
# replace template vars with data provided


class OpenScadTemplate

  def initialize (
    _dailyActivity, 
    _dailyTotals,
    _goalTarget = 0,
    _startDate = "",
    _endDate = "",
    _name = ""
  )
    @dailyActivity =  _dailyActivity
    @dailyTotals =    _dailyTotals
    @goalTarget =     _goalTarget
    @startDate =      _startDate
    @endDate =        _endDate
    @name =           _name
    
    @filename = File.join(File.dirname(__FILE__), '../openscad/nike-template.scad')
  end

  # return the updated template file
  def customizeTemplate( 
                        _displayFormat = "points" # specify the type {values, points}
                       )

    template = File.read(@filename)


    template.sub!('*****DETAIL*****', @dailyActivity.to_s)
    template.sub!('*****BADGES*****', [].to_s) # empty for now.
    template.sub!('*****FORMAT*****', "\"#{_displayFormat}\"")

    template.sub!('*****TOTAL*****',  @dailyTotals.to_s)
    template.sub!('*****TARGET*****', @goalTarget.to_s)
    template.sub!('*****START*****',  "\"#{@startDate}\"")
    template.sub!('*****END*****',    "\"#{@endDate}\"")
    template.sub!('*****NAME*****',   "\"#{@name}\"")

    return template
  end

end


