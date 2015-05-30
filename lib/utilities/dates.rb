module Utilities::Dates

  LONG_MONTHS  = %w{january february march april may june july august september october november december}
  SHORT_MONTHS = %w{jan feb mar apr may jun jul aug sep oct nov dec}
  ROMAN_MONTHS = %i{i ii iii iv v vi vii viii ix x xi xii}

  MONTHS_FOR_SELECT = LONG_MONTHS.collect { |m| [m.capitalize, LONG_MONTHS.index(m) + 1] }

  # This following is the better long term approach than using
  # a preset LEGAL_MONTHS, as it depends on extending
  # SHORT_MONTH_FILTER correctly.
  #    SHORT_MONTHS.include?(SHORT_MONTH_FILTER[value].to_s)
  LEGAL_MONTHS      = (1..12).to_a +
    (1..12).to_a.collect { |d| d.to_s } +
    ROMAN_MONTHS.map(&:to_s) +
    ROMAN_MONTHS.map(&:to_s).map(&:upcase) +
    SHORT_MONTHS +
    SHORT_MONTHS.map(&:capitalize) +
    SHORT_MONTHS.map(&:upcase) +
    SHORT_MONTHS.map(&:to_sym) +
    LONG_MONTHS +
    LONG_MONTHS.map(&:capitalize) +
    LONG_MONTHS.map(&:upcase)
  LONG_MONTHS.map(&:to_sym)

  # TODO: Write unit tests
  # Concept from from http://www.rdoc.info/github/inukshuk/bibtex-ruby/master/BibTeX/Entry
  # Converts integers, month names, or roman numerals, regardless of class to three letter symbols.
  #   SHORT_MONTH_FILTER[1]         # => :jan
  #   SHORT_MONTH_FILTER['JANUARY'] # => :jan
  #   SHORT_MONTH_FILTER['i']       # => :jan
  #   SHORT_MONTH_FILTER['I']       # => :jan
  #   SHORT_MONTH_FILTER['foo']     # => 'foo':
  SHORT_MONTH_FILTER =
    Hash.new do |h, k|
      v = k.to_s.strip
      if v =~ /^(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/i
        h[k] = v[0, 3].downcase.to_sym
      else
        i = nil
        if v =~ /^\d\d?$/
          i = v.to_i
        elsif ROMAN_MONTHS.include?(v.downcase.to_sym)
          i = ROMAN_MONTHS.index(v.downcase.to_sym) + 1
        end

        if !i.nil? && i > 0 && i < 13
          h[k] = DateTime.new(1, i, 1).strftime("%b").downcase.to_sym
        else # return the value passed if it doesn't match
          k
        end
      end
    end

  # @return[Time] a UTC time (Uses Time instead of Date so that it can be saved as a UTC object -
  #   See http://www.ruby-doc.org/core-2.0.0/Time.html)
  #   Returns nomenclature_date based on computation of the values of :year, :month, :day.
  #    if :year is empty, return nil
  #    if :month is empty, returns 12/31/:year
  #    if :day is empty, returns the last day of the month
  def self.nomenclature_date(day = nil, month = nil, year = nil)
    if year.nil?
      nil
    elsif month.nil?
      Time.utc(year, 12, 31)
    elsif day.nil?
      tmp = Time.utc(year, month)
      if tmp.month == 12 # want the last day of december
        Time.utc(year, 12, 31)
      else # time + 1 month - 1 day (60 sec * 60 min *24 hours)
        Time.utc(year, tmp.month + 1) - 86400
      end
    else
      Time.utc(year, month, day)
    end
  end

  def mdy_parse_date(date_string)
    date_string
  end

  # @return [String] of sql to test dates
  # @param [Hash] params
  # TODO: still needs more work for some date combinations
  def self.date_sql_from_params(params)
    st_date, end_date         = params['st_datepicker'], params['en_datepicker']
# processing start date data
    st_year, st_month, st_day = params['start_date_year'], params['start_date_month'], params['start_date_day']
    unless st_date.blank?
      parts                     = st_date.split('/')
      st_year, st_month, st_day = parts[2], parts[0], parts[1]
    end
    st_my                        = (!st_month.blank? and !st_year.blank?)
    st_m                         = (!st_month.blank? and st_year.blank?)
    st_y                         = (st_month.blank? and !st_year.blank?)
    st_blank                     = (st_year.blank? and st_month.blank? and st_day.blank?)
    st_full                      = (!st_year.blank? and !st_month.blank? and !st_day.blank?)
    st_partial                   = (!st_blank and (st_year.blank? or st_month.blank? or st_day.blank?))
# start_time                   = fix_time(st_year, st_month, st_day) if st_full

# processing end date data
    end_year, end_month, end_day = params['end_date_year'], params['end_date_month'], params['end_date_day']
    unless end_date.blank?
      parts                        = end_date.split('/')
      end_year, end_month, end_day = parts[2], parts[0], parts[1]
    end
    end_my      = (!end_month.blank? and !end_year.blank?)
    end_m       = (!end_month.blank? and end_year.blank?)
    end_y       = (end_month.blank? and !end_year.blank?)
    end_blank   = (end_year.blank? and end_month.blank? and end_day.blank?)
    end_full    = (!end_year.blank? and !end_month.blank? and !end_day.blank?)
    end_partial = (!end_blank and (end_year.blank? or end_month.blank? or end_day.blank?))
# end_time    = fix_time(end_year, end_month, end_day) if end_full

    sql_string  = ''
# if all the date information is blank, skip the date testing
    unless st_blank and end_blank
      # only start and end year
      if st_y and end_y
        # start and end year may be different, or the same
        # we ignore all records which have a null start year,
        # but include all records for the end year test
        sql_string += "(start_date_year >= #{st_year} and (end_date_year is null or end_date_year <= #{end_year}))"
      end

      # only start month and end month
      if st_m and end_m
        # todo: This case really needs additional consideration
        # maybe build a string of included month and use an 'in ()' construct
        sql_string += "(start_date_month between #{st_month} and #{end_month})"
      end

      if end_blank # !st_blank = st_partial
        # if we have only a start date there are three cases: d/m/y, m/y, y
        if st_year.blank?
          sql_string = add_st_month(sql_string, st_month)
        else
          sql_string = add_st_day(sql_string, st_day)
          sql_string = add_st_month(sql_string, st_month)
          sql_string = add_st_year(sql_string, st_year)
        end
      else
        # end date only, don't do anything
      end

      if ((st_y or st_my) and (end_y or end_my)) and not (st_y and end_y)
        # we have two dates of some kind, complete with years
        # three specific cases:
        #   case 1: start year, (start month, (start day)) forward
        #   case 2: end year, (end month, (end day)) backward
        #   case 3: any intervening year(s) complete
        if st_year
        end
      end
    end
    sql_string
  end

  # Pass integers
  def self.format_to_hours_minutes_seconds(hour, minute, second)
    h, m, s = nil, nil, nil
    h       = ("%02d" % hour) if hour
    m       = ("%02d" % minute) if minute
    s       = ("%02d" % second) if second
    [h, m, s].compact.join(":")
  end

  private_class_method

  # @param [String] sql
  # @param [Integer] st_year
  # @return [String] of sql
  def self.add_st_year(sql, st_year)
    unless st_year.blank?
      unless sql.blank?
        prefix = ' and '
      end
      sql += "#{prefix}(start_date_year = #{st_year})"
    end
    sql
  end

  # @param [String] sql
  # @param [Integer] st_month
  # @return [String] of sql
  def self.add_st_month(sql, st_month)
    unless st_month.blank?
      unless sql.blank?
        prefix = ' and '
      end
      sql += "#{prefix}(start_date_month = #{st_month})"
    end
    sql
  end

  # @param [String] sql
  # @param [Integer] st_day
  # @return [String] of sql
  def self.add_st_day(sql, st_day)
    unless st_day.blank?
      unless sql.blank?
        prefix = ' and '
      end
      sql += "#{prefix}(start_date_day = #{st_day})"
    end
    sql
  end

  # @param [Integer] year
  # @param [Integer] month
  # @param [Integer] day
  # @return [Time]
  def self.fix_time(year, month, day)
    start = Time.new(1970, 1, 1)
    if year.blank?
      year = start.year
    end
    if month.blank?
      month = start.month
    end
    if day.blank?
      day = start.day
    end
    Time.new(year, month, day)
  end

end
