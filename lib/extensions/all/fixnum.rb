require 'extensions/all/modules/seconds_to_time'
require 'extensions/all/modules/percent'

class Fixnum

  include Extensions::All::Modules::SecondsToTime
  include Extensions::All::Modules::Percent
  
  
end