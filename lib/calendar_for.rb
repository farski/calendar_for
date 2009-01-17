module CalendarHelper
  # Creates a calendar table for a given date within a specified timeframe.
  # Generic usage:
  # <%= calendar_for { |day| render :partial => 'day', :locals => { :day => day } } %>
  # This will default to the current time in a month timeframe.
  # The date can be specified as a Date or Time object, as a string to be parsed by Chronic, or a hash like { :year => 2001, :month => 6 }
  # Options:
  # :week_start, the first day of the week, as an integer (0=Sunday, 6=Saturday), string ("Friday"), or symbol (:monday); default is Sunday.
  # :timeframe, default is :month. others are, :year (starting with january), :quarter, :week, Integer (e.g. 12 would be specified month and the next 11)
  # :html_classes, a hash to set custom class attributes for special TD tags, :today when the current day is displayed (default "today"), 
  #                 and :out_of_timeframe, eg when June 1 is a Friday and the week_start is Monday, the first four days shown are out_of_timeframe.
  #                 The class of tables (calendars) can be set with :calendar
  # :weekday_headers, to suppress a row of <th>Monday</th>... set to false, to replace standard "Monday", "Tuesday", supply an array
  # Complex use:
  # calendar_for({ :year => 1962 }, :week_start => :monday, :timeframe => 24, :html_classes => { :today => 'current' }, :weekday_headers => false) { |day| content_tag(:h1, day.day) }
  def calendar_for(date_or_time_object_or_parameters = Time.now, *args, &block)
    raise ArgumentError, "Missing block" unless block_given?

    options = args.extract_options!
    
    options[:html_classes] ||= Hash.new
    options[:html_classes][:calendar] ||= "calendar"
    options[:html_classes][:today] ||= "today"
    options[:html_classes][:out_of_timeframe] ||= "null"
    
    weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    options[:week_start] ||= 0
    case options[:week_start]
    when Integer
      week_start = options[:week_start]
    when String, Symbol
      week_start = weekdays.index(options[:week_start].to_s.capitalize)
    end    
    unless options[:weekday_headers] == false
      weekdays = options[:weekday_headers] if (options[:weekday_headers].is_a?(Array) && options[:weekday_headers].size == 7 )
      table_headers = Array.new
      week_start.times { weekdays << weekdays.shift }
      weekdays.each { |w| table_headers << content_tag(:th, w) }
      table_headers_row = content_tag(:tr, table_headers.join)
    end 
        
    case date_or_time_object_or_parameters
    when Date, Time
      timeframe_starts_on = date_or_time_object_or_parameters
    when String
      timeframe_starts_on = Chronic.parse(date_or_time_object_or_parameters)
    when Hash
      date_params = date_or_time_object_or_parameters
      timeframe_starts_on = Time.local(date_params[:year], date_params[:month], date_params[:day])
    end    
  
    case options[:timeframe]
    when :day
      months, weeks, days = 1, 1, 1
      calendar_starts_on = timeframe_starts_on.midnight
    when :week
      calendar_starts_on = timeframe_starts_on.midnight.monday.advance(:days => (week_start-1))
      months, weeks = 1, 1
    when :quarter
      months = 4
      calendar_starts_on = timeframe_starts_on.midnight.beginning_of_quarter.monday.advance(:days => (week_start-1))
      timeframe_starts_on = timeframe_starts_on.beginning_of_quarter
    when :year
      months = 12
      calendar_starts_on = timeframe_starts_on.midnight.beginning_of_year.monday.advance(:days => (week_start-1))
      timeframe_starts_on = timeframe_starts_on.beginning_of_year
    when Integer
      months = options[:timeframe]
      calendar_starts_on = timeframe_starts_on.midnight.beginning_of_month.monday.advance(:days => (week_start-1))
    else
      months = 1
      calendar_starts_on = timeframe_starts_on.midnight.beginning_of_month.monday.advance(:days => (week_start-1))
    end
    
    tables = Array.new
    months.times do |m|
      table_rows = Array.new
      table_rows << table_headers_row if table_headers_row
      weeks ||= ((timeframe_starts_on.end_of_month - calendar_starts_on)/(7.days)).ceil
      weeks.times do |w|
        table_cells = Array.new
        (days || 7).times do |d|
          current_date = calendar_starts_on.advance(:days => (w*7+d))
          if current_date.midnight == Time.now.midnight
            html_class = options[:html_classes][:today]
          elsif current_date.month != timeframe_starts_on.month
            html_class = options[:html_classes][:out_of_timeframe]
          end
          table_cells << content_tag(:td, yield(current_date), :class => html_class)
        end
        table_rows << content_tag(:tr, table_cells.join)
      end
      weeks = nil
      html_rel = timeframe_starts_on.strftime('%Y%m%d')
      timeframe_starts_on = timeframe_starts_on.advance(:months => 1)
      calendar_starts_on = timeframe_starts_on.midnight.beginning_of_month.monday.advance(:days => (week_start-1))
      tables << content_tag(:table, table_rows.join, :class => options[:html_classes][:calendar], :rel => html_rel)
    end
    
    return tables  
  end
end

ActionView::Base.send :include, CalendarHelper