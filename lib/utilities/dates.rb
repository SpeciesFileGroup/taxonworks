module Utilities::Dates

  LONG_MONTHS  = %w{january february march april may june july august september october november december}
  SHORT_MONTHS = %w{jan feb mar apr may jun jul aug sep oct nov dec}
  ROMAN_MONTHS = %i{i ii iii iv v vi vii viii ix x xi xii}

  # This following is the better long term approach than using 
  # a preset LEGAL_MONTHS, as it depends on extending
  # SHORT_MONTH_FILTER correctly.
  #    SHORT_MONTHS.include?(SHORT_MONTH_FILTER[value].to_s)
  LEGAL_MONTHS = (1..12).to_a + 
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
    Hash.new do |h,k|
      v = k.to_s.strip
      if v =~ /^(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/i
        h[k] = v[0,3].downcase.to_sym
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

  # Pass integers
  def self.format_to_hours_minutes_seconds(hour, minute, second) 
    h, m, s = nil, nil, nil
    h = ("%02d" % hour) if hour
    m = ("%02d" % minute) if minute
    s = ("%02d" % second) if second
    [h, m, s].compact.join(":")
  end

end
