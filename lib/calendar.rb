module CalendarFor
  class Calendar
    def initialize(aTime = Time.now)
      @time = aTime
      @weeks_start_on = 0 # 0 = sunday
      @weekday_names = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
    end
    
    def month
      
    end
    
    def week
      week = []
      7.times do |i|
        week << @time.midnight.monday.advance(:days => (week_start-1))
      end
      week
    end
    
    def day
      [@time.mday]
    end
  end
  
  module CalendarHelper
    def calendar_for(date_or_time_object_or_parameters = Time.now, *args, &block)
      
    end
  end
end

c=CalendarFor::Calendar.new()
puts c.week