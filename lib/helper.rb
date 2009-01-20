module CalendarHelper
  
  def calendar_for(date_or_time_object_or_parameters = Time.now, *args, &block)
    raise ArgumentError, "Missing block" unless block_given?
    
    options = default_missing_options(args.extract_options!)
    options[:week_starts_on] = numeralize_week_starts_on_option(options)
    options[:scope_starts_on] = chronolize_scope_starts_on_option(date_or_time_object_or_parameters)
    options[:view_parameters] = bound_view_in_scope(options)
    options[:scope_starts_on] = adjust_for_long_term_scope(options)
    
    html = build_table_view(options, block)
  end
  
  private
  
  def default_missing_options(options)
    options[:week_starts_on] ||= 0
    options[:scope] ||= :month
    options[:weekday_names] ||= ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    options[:surpress_weekday_headers] ||= false
    
    return options
  end
  
  def numeralize_week_starts_on_option(options)
    case options[:week_starts_on]
      when Integer then options[:week_starts_on]
      when String, Symbol then options[:weekday_names].index(options[:week_starts_on].to_s)
    end  
  end
  
  def chronolize_scope_starts_on_option(time)
    case time
      when Date, Time then time
      when String then Chronic.parse(time)
      when Hash then Time.local(time[:year], time[:month], time[:day])
    end   
  end
  
  def bound_view_in_scope(options)
    view_params = Hash.new
    week_start_adjuster = (options[:week_starts_on] - 1)
    
    case options[:scope]
    when :day
      view_params[:days] = 1
      view_params[:weeks] = 1
      view_params[:months] = 1
      view_params[:starts_on] = options[:scope_starts_on].midnight
    when :week
      view_params[:weeks] = 1
      view_params[:months] = 1
      view_params[:starts_on] = options[:scope_starts_on].monday.midnight.advance(:days => week_start_adjuster)
    when :quarter
      view_params[:months] = 4
      view_params[:starts_on] = options[:scope_starts_on].beginning_of_quarter.monday.midnight.advance(:days => week_start_adjuster)
    when :year
      view_params[:months] = 12
      view_params[:starts_on] = options[:scope_starts_on].beginning_of_year.monday.midnight.advance(:days => week_start_adjuster)
    when Integer
      view_params[:months] = options[:scope]
      view_params[:starts_on] = options[:scope_starts_on].beginning_of_month.monday.midnight.advance(:days => week_start_adjuster)
    end
    
    return view_params    
  end
  
  def adjust_for_long_term_scope(options)
    case options[:scope]
      when :quarter then options[:scope_starts_on].beginning_of_quarter
      when :year then options[:scope_starts_on].beginning_of_year
    end
  end
  
  def build_table_view(options, block)
    table = Markup::Element.new(:table)
    
    headers = build_table_headers(options)
    table.push(headers) unless options[:surpress_weekday_headers] == true
    
    rows = build_table_rows(options)
    table.push(rows)
  end
  
  def build_table_headers(options)
    tr = Markup::Element.new(:table)
    options[:weekday_names].each { |name| Markup::Element.new(:th) { name }.inject_into(tr) }
  end

  def build_table_rows(options)
    
  end
end