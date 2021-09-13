# TODO: Extract to gem
#  - remove reference to `blank?` (no Rails methods)
#  - use && not `and` ?
#
#  In Ruby
#    Time.now.strftime("%Y-%m-%d") gets the commonly used yyyy-mm-dd
module Utilities::Dates

  EARLIEST_DATE = '1700/01/10'.freeze # Reconcile with in-app

  LONG_MONTHS = %w{january february march april may june july august september october november december}.freeze
  SHORT_MONTHS = %w{jan feb mar apr may jun jul aug sep oct nov dec}.freeze
  ROMAN_MONTHS = %i{i ii iii iv v vi vii viii ix x xi xii}.freeze

  MONTHS_FOR_SELECT = LONG_MONTHS.collect {|m| [m.capitalize, LONG_MONTHS.index(m) + 1]}

  # This following is the better long term approach than using
  # a preset LEGAL_MONTHS, as it depends on extending
  # SHORT_MONTH_FILTER correctly.
  #    SHORT_MONTHS.include?(SHORT_MONTH_FILTER[value].to_s)
  LEGAL_MONTHS = (1..12).to_a +
    (1..12).to_a.collect {|d| d.to_s} +
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
          h[k] = DateTime.new(1, i, 1).strftime('%b').downcase.to_sym
        else # return the value passed if it doesn't match
          k
        end
      end
    end

  REGEXP_DATES = {
      month_dd_yyyy_2: {reg: /(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\.?[\s,\/]\s?(\d\d?)[\.;,]?[\s\.,\/](\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})\s?[-\u2013\/]\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\.?[\s,\/]\s?(\d\d?)[\.;,]?[\s,\/]\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                        hlp: 'June 27 1946 - July 1 1947',
                        hdr: 'mody2'},

      # dd_month_yyyy_2: {reg: /(\d\d?)[\.,\/]?\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\s?\.?[\s,\/]?\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})\s?[-\.,\/]?\s?(\d\d?)[\.,\/]?\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\s?\.?[\s,\/]?\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
      dd_month_yyyy_2: {reg: /(\d\d?)\s*[-\.,\/]?\s*(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\s*[-\.\s,\/]?\s*(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})\s?[-\.,\/]?\s?(\d\d?)\s*[-\.,\/]?\s*(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\s*[-\.\s,\/]?\s*(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                        hlp: '27 June 1946 - 1 July 1947',
                        hdr: 'dmoy2'},

      mm_dd_yyyy_2: {reg: /(\d\d?)[\s,\.\/]\s?(\d\d?)[\.,]?[\s\.,\/](\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\?\d{2})\s?[-\u2013\/]\s?(\d\d?)[\s,\.\/]\s?(\d\d?)[\.,]?[\s,\/]\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                     hlp: '5 27 1946 - 6 1 1947',
                     hdr: 'mdy2'},

      month_dd_month_dd_yyyy: {reg: /(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\.?[\s,\/]?\s?(\d\d?)\s?[-\u2013\/]\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\.?[\s,\/]?\s?(\d\d?)[\s\.;,\/]\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                               hlp: 'June 27 - July 1 1947',
                               hdr: 'modmody2'},

      dd_month_dd_month_yyyy: {reg: /(\d\d?)\s?[\.\/,\u2013-]?\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\.?\s?[-\u2013\/]\s?(\d\d?)\s?[-\s\u2013_\.,\/]?\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\.?\s?[-,\u2013\/]?\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                               hlp: '27 June - 1 July 1947',
                               hdr: 'dmodmoy2'},

      dd_mm_dd_mm_yyyy: {reg: /(\d\d?)[\s\.,\/]\s?(\d\d?)\s?[-\u2013\/]\s?(\d\d?)[\s\.,\/]\s?(\d\d?)[\s\.,\/]\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                         hlp: '14.6-17.6.1994',
                         hdr: 'dmdmy2'},

      mm_dd_mm_dd_yyyy: {reg: /(\d\d?)[\s\.,\/]\s?(\d\d?)\s?[-\u2013\/]\s?(\d\d?)[\s\.,\/]\s?(\d\d?)[\s\.,\/]\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                         hlp: '5 27 - 6 1 1947 | 5/ 26- 6/ 26 1944',
                         hdr: 'mdmdy2'},

      month_dd_dd_yyyy: {reg: /(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)[\.,]?[-\s\u2013,\/]?(\d\d?)\s?[-\u2013\+\/]\s?(\d\d?)[\.,]?[-\s\.\u2013,\/]\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                         hlp: 'June 27-29 1947',
                         hdr: 'moddy2'},

      dd_dd_month_yyyy: {reg: /(\d\d?)\s?[-\u2013\+\/]\s?(\d\d?)[\s\.,\/-]\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\.?[-\s\u2013,\/]?\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                         hlp: '27-29 June 1947',
                         hdr: 'ddmoy2'},

      # mm_dd_mm_dd_yyyy:    /(\d\d?)[\s\.,\/]\s?(\d\d?)\s?[-\u2013\/]\s?(\d\d?)[\s\.,\/]\s?(\d\d?)[\s\.,\/]\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
      # mm_dd_dd_yyyy:     /(\d\d?)\s?[-\u2013\s\.,\/]\s?(\d\d?)\s?[-\u2013\+\/]\s?(\d\d?)[\.,;]?\s?[-\s\u2013,\/](\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
      #  THIS REGEX HAS ISSUES WITH THE FIRST EXAMPLE BUT ERRONEOUSLY WORKS FOR THE SECOND
      # (\d\d?)\s?[-\u2013\s\.,\/]\s?(\d\d?)\s?[-\u2013\+\/]\s?(\d\d?)[\.,;]?\s?[-\u2013\+\/]\s?(\d\d?)[\.,;]?\s?[-\s\u2013,\/](\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2,4})

      mm_dd_dd_yyyy: {reg: /(\d\d?)\s?[-\u2013\s\.,\/]\s?(\d\d?)\s?[-\u2013\+\/]\s?(\d\d?)[\.,;]?\s?[-\u2013\+\/]?\s?[\.,;]?\s?[-\s\u2013,\/]?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2,4})/i,
                      hlp: ' 5 27-29 1947',
                      hdr: 'mddy2'},

      month_dd_yyy: {reg: /(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\.?\s?[-\u2013_,\/]?\s?(\d\d?)[\.;,]?\s?[-\s\u2013_\/\.\u0027,]\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                     hlp: "Jun 29 1947 | Jun 29, 1947 | June 29 1947 | June 29, 1947 | VI-29-1947 | X.25.2000 | Jun 29, '47 | June 29, '47 | VI-4-08 | Jun 29, '47",
                     hdr: 'mody'},

      dd_month_yyy: {reg: /(\d\d?)\s?[-\u2013_\.,\/]?\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)[\.,]?\s?[-,\u2013_\/]?\s?(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                     hlp: "29 Jun 1947 | 29 June 1947 | 2 June, 1983 | 29 VI 1947 | 29-VI-1947 | 25.X.2000 | 25X2000 | 29 June '47 | 29 Jun '47",
                     hdr: 'dmoy'},

      mm_dd_yyyy: {reg: /(\d\d?)[-\s\u2013_\.,\/]\s?(\d\d?)[-\s\u2013_\.,\/]\s?(\d{4})/i,
                   hlp: '6/29/1947 | 6-29-1947 | 6-15 1985 | 10.25 2000 | 7.10.1994',
                   hdr: 'mdy'},

      mm_dd_yy: {reg: /(\d\d?)[-\s\u2013_\.,\/]\s?(\d\d?)[-\s\u2013_\.,\/]\s?([\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                 hlp: "6/29/47 | 6/29/'47 | 7.10.94 | 5-17-97",
                 hdr: 'mdy'},

      dd_mm_yy: {reg: /(\d\d?)[-\s\u2013_\.,\/]\s?(\d\d?)[-\s\u2013_\.,\/]\s?([\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})/i,
                 hlp: "29/9/47 | 29/9/'47 | 7.10.94 | 15-07-97",
                 hdr: 'dmy'},

      yyyy_mm_dd: {reg: /(\d{4})[-\s\u2013_\.,\/]\s?(\d\d?)[-\s\u2013_\.,\/]\s?(\d\d?)/i,
                   hlp: '1994, 4.16 | 1902-04-24',
                   hdr: 'yyymd'},

      yyy_mm_dd: {reg: /(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})[-\s\u2013_\.,\/]\s?(\d\d?)[-\s\u2013_\.,\/]\s?(\d\d?)/i,
                  hlp: "1994, 4.16 | '02-04-24 | 02-04-24",
                   hdr: 'ymd'},

      yyyy_month_dd: {reg: /(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})[-\s\u2013_\.,\/]?\s*(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)[-\s\u2013_\.,\/]?\s*(\d\d?)/i,
                      hlp: '1994 JULY 17 | 2003 June 15 -  2004 July 04 | 2002-IV-27 - 2008-JUL-04',
                      hdr: 'ymod'},

      yyyy_mm_dd_mm_dd: {reg: /(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})[-\s\u2013_\.,\/]\s?(\d\d?)[-\s\u2013_\.,\/]\s?(\d\d?)[-\s\u2013_\.,\/]\s?(\d\d?)[-\s\u2013_\.,\/]\s?(\d\d?)/i,
                         hlp: '1994, 6.14-6.17',
                         hdr: 'ymdmd'},

      yyyy_month_dd_month_dd: {reg: /(\d{4}|[\u0027´`\u02B9\u02BC\u02CA]?\s?\d{2})[-\s\u2013_\.,\/]?\s*(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)[-\s\u2013_\.,\/]?\s*(\d\d?)\s?[-\s\u2013_\.,\/]?\s*(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)[-\s\u2013_\.,\/]?\s*(\d\d?)/i,
                               hlp: '1994 june 14 -JULY 17 | 2002-IV-27 - JUL-04',
                               hdr: 'ymodmod'}
  }.freeze

  class DateFromLabel
    attr_reader(:verbatim_label, :date)

    # @param [String] label
    def initialize(label)
      @verbatim_label = label
      @date = Utilities::Dates.date_regex_from_verbatim_label(label)
    end
  end


  # @param [String]
  # @param [Integer]
  # @param [Symbol]
  # @return [Integer]
  #    return the month index
  def self.month_index(month_value)
    return nil if month_value.blank?
    month_test = SHORT_MONTH_FILTER[month_value]
    return nil if month_test.to_s.to_i > 11 # this is to filter out numeric values > 11, symbols => 0
    retval = SHORT_MONTHS.index(month_test.to_s) + 1
    return nil if retval > 12
    retval
  end

  # @param date [Date]
  # @return [String]
  #   yyyy-mm-dd
  def self.date_string(date)
    "#{'%4d' % date.year}-#{'%02d' % date.month}-#{'%02d' % date.day}" unless date.nil?
  end

  # @return String
  #   A date string unambiguosly formatted in yyyy/mm/dd.  Always includes all parts indicating
  #   not available parts with '?'
  def self.from_parts(y, m, d)
    return '????/??/??' if y.nil? && m.nil? && d.nil?
    [y ? "#{y}" : '????',
     m ? "#{'%02d' % m}" : '??',
     d ? "#{'%02d' % d}" : '??'
    ].join('/')
  end

  # @params [year: integer]
  # @params [month: integer, nil]
  # @params [day: integer, nil]
  # @return[Time] a UTC time (Uses Time instead of Date so that it can be saved as a UTC object -
  #   See http://www.ruby-doc.org/core-2.0.0/Time.html)
  #   Returns nomenclature_date based on computation of the values of :year, :month, :day.
  #    if :year is empty, return nil
  #    if :month is empty, returns 12/31/:year
  #    if :day is empty, returns the last day of the month
  #
  # Use self.month_index to convert months prior to handling them here
  #
  def self.nomenclature_date(day = nil, month = nil, year = nil)
    if year.nil?
      nil
    elsif month.nil?
      Time.utc(year.to_i, 12, 31)
    elsif day.nil?
      tmp = Time.utc(year.to_i, month.to_i)
      if tmp.month == 12 # want the last day of december
        Time.utc(year.to_i, 12, 31)
      else # time + 1 month - 1 day (60 sec * 60 min *24 hours)
        Time.utc(year.to_i, tmp.month + 1) - 86400
      end
    else
      Time.utc(year.to_i, month.to_i, day.to_i)
    end
  end

  # !#!@# Deprecate this! It's handled in CollectingEVent date filter code
  # @return [String] of sql to test dates
  # @param [Hash] params
  # TODO: still needs more work for some date combinations
  def self.date_sql_from_params(params)
    st_date, end_date = params['st_datepicker'], params['en_datepicker']
    # processing start date data
    st_year, st_month, st_day = params['start_date_year'], params['start_date_month'], params['start_date_day']
    unless st_date.blank?
      parts = st_date.split('/')
      st_year, st_month, st_day = parts[2], parts[0], parts[1]
    end
    st_my = (!st_month.blank? and !st_year.blank?)
    st_m = (!st_month.blank? and st_year.blank?)
    st_y = (st_month.blank? and !st_year.blank?)
    st_blank = (st_year.blank? and st_month.blank? and st_day.blank?)
    # st_full = (!st_year.blank? and !st_month.blank? and !st_day.blank?)

    # st_partial = (!st_blank and (st_year.blank? or st_month.blank? or st_day.blank?))
    # start_time = fix_time(st_year, st_month, st_day) if st_full

    # processing end date data
    end_year, end_month, end_day = params['end_date_year'], params['end_date_month'], params['end_date_day']
    unless end_date.blank?
      parts = end_date.split('/')
      end_year, end_month, end_day = parts[2], parts[0], parts[1]
    end
    end_my = (!end_month.blank? and !end_year.blank?)
    end_m = (!end_month.blank? and end_year.blank?)
    end_y = (end_month.blank? and !end_year.blank?)
    end_blank = (end_year.blank? and end_month.blank? and end_day.blank?)

    # end_full = (!end_year.blank? and !end_month.blank? and !end_day.blank?)
    # end_partial = (!end_blank and (end_year.blank? or end_month.blank? or end_day.blank?))
    # end_time = fix_time(end_year, end_month, end_day) if end_full

    sql_string = ''
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
  # @param [Integer] hour
  # @param [Integer] minute
  # @param [Integer] second
  # @return [String]
  def self.format_to_hours_minutes_seconds(hour, minute, second)
    h, m, s = nil, nil, nil
    h = ('%02d' % hour) if hour
    m = ('%02d' % minute) if minute
    s = ('%02d' % second) if second
    [h, m, s].compact.join(':')
  end

  # Parse an ISO-8601 date string or interval into an array of OpenStructs objects
  #
  # The format may be yyyy-mm-dd or yyyy-mm-dd/yyyy-mm-dd.
  # The second date may omit higher-order elements that are the same as the first date, like yyyy-mm-dd/dd or yyyy-mm-dd/mm-dd
  # See https://en.wikipedia.org/wiki/ISO_8601#Time_intervals for more details.
  #
  # @param [String] date_str The date string to parse
  # @return [Array<OpenStruct>] Array of Date objects, with year, mmonth, day, hour, minute, and second properties
  def self.parse_iso_date_str(date_str)

    full_pattern = %r{^
          (?<year>[0-9]{4})(-(?<month>[0-9]{1,2}))?(-(?<day>[0-9]{1,2}))?  # Date in these formats: YYYY | YYYY-M(M)? | YYYY-M(M)?-D(D)?
          (
            T(?<hour>[0-9]{2}):(?<minute>[0-9]{2}):(?<second>[0-9]{2})(Z)? # Optional time, only THH:MM:SS(Z)? allowed.
          )?
        $}x.freeze

    if date_str.include? "/"
      first_date_str, second_date_str = date_str.split('/', 2)

      first_date_hash = first_date_str.match(full_pattern)&.named_captures&.transform_values! { |v| v&.to_i }

      return nil unless first_date_hash

      # Split date on separators, then work backwards inserting numbers for non-null values from first date
      second_date_values = second_date_str.split(/[-T:Z]/).map { |x| x.to_i }


      # keep non-nil values in first date string
      present_date_hash = first_date_hash.reject { |_,v| v.nil? }

      # Sort the keys present in the first date, smallest increment first
      date_order = [:second, :minute, :hour, :day, :month, :year]
      present_keys = present_date_hash.sort_by {|key, _| date_order.index(key.to_sym)}.map{|pair| pair[0]}

      # zip keys with values from second date and drop the extra keys
      new_values = present_keys.zip(second_date_values.reverse).to_h.reject { |_,v| v.nil? }

      # make new date from first, updating with values from second
      second_date_hsh = first_date_hash.clone.update(new_values)

      [OpenStruct.new(first_date_hash), OpenStruct.new(second_date_hsh)]

    else
      named_captures = date_str.match(full_pattern)&.named_captures&.transform_values! { |v| v&.to_i } # Not (&:to_i) because it would replace nil with 0

      return nil unless named_captures
      [OpenStruct.new(named_captures)]
    end
  end

  private

  # @param [String] sql
  # @param [Integer] st_year
  # @return [String] of sql
  def self.add_st_year(sql, st_year)
    unless st_year.blank?
      prefix = sql.blank? ? '' : ' and '
      sql += "#{prefix}(start_date_year = #{st_year})"
    end
    sql
  end

  # @param [String] sql
  # @param [Integer] st_month
  # @return [String] of sql
  def self.add_st_month(sql, st_month)
    unless st_month.blank?
      prefix = sql.blank? ? '' : ' and '
      sql += "#{prefix}(start_date_month = #{st_month})"
    end
    sql
  end

  # @param [String] sql
  # @param [Integer] st_day
  # @return [String] of sql
  def self.add_st_day(sql, st_day)
    unless st_day.blank?
      prefix = sql.blank? ? '' : ' and '
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

  # @param [String] start_date in the form of 'yyyy*mm*dd'
  # @param [String] end_date in the form of 'yyyy*mm*dd'
  # @return [String, String] start_date, end_date
  #   - orders dates from start to end (if they were passed incorrectly)
  #   - creates a one-day range (duplicates the only date) if only one date is provided
  #   - creates a date range from EARLIEST_DATE to Today if none provided
  def self.normalize_and_order_dates(start_date, end_date)
    if start_date.blank? && end_date.blank? # set entire range
      [ EARLIEST_DATE, today] # 1700-01-01 - Today
    else
      end_date = start_date if end_date.blank?
      start_date = end_date if start_date.blank?
      order_dates(start_date, end_date)
    end
  end

  # @return [String]
  def self.today
    Time.zone.today.strftime('%Y-%m-%d')
  end

  # @param [Array] label of strings
  # @param [Array] pieces of strings
  # @return [Array] of strings
  def self.make_verbatim_date_piece(label, pieces)
    left = label.index(pieces[0])
    right = left + pieces[0].length - 1 #
    unless pieces[1].blank?
      right = label.index(pieces[1]) + pieces[1].length - 1
    end
    label[left..right]
  end

  # @param [String] start_date in the form of 'yyyy-mm-dd'
  # @param [String] end_date in the form of 'yyyy-mm-dd'
  # @return [String, String] start_date, end_date in proper order
  def self.order_dates(start_date, end_date)
    if Date.parse(start_date) > Date.parse(end_date) # need to swap s and e?
      start_date, end_date = end_date, start_date
    end
    return start_date, end_date
  end

  # @param [Array] of 0-2 dates
  # @return [String, nil]
  #   a sentence spelling out the date range
  def self.date_range_sentence_tag(date_range)
    format = '%d-%b-%Y'
    date_range.compact!
    date_range.pop if date_range[0] == date_range[1]
    if date_range.empty?
      nil
    else
      if date_range.size == 2
        'Records exist in the date range ' + date_range.collect {|d| d.strftime(format)}.join(' to ') + '.'
      elsif date_range.size == 1
        "A record exists from #{date_range.first.strftime(format)}."
      else
        'Hmm, that is a curious date range!'
      end
    end
  end

  # @param [String] year
  # @return [String]
  def self.fix_2_digit_year(year)
    if year.length < 4
      year = year.gsub("'", '')
      if year.length < 3
        tny = Time.now.year
        if year.to_i > tny%100
          year = ((tny/100) - 1).to_s + year
        else
          year = (tny/100).to_s + year
        end
      end
    end
    year
  end

  # @param [String] label
  # @param [Array] filters of regexes
  # @return [Array] of possible interpretations of dates
  def self.hunt_dates(label, filters = REGEXP_DATES.keys)
    trials = {}
    filters.each_with_index {|kee, dex|
      trials[kee] = {}
      matches = label.to_enum(:scan, REGEXP_DATES[kee][:reg]).map {Regexp.last_match}
      unless matches.blank?
        trials[kee][:method] = kee
        trials[kee][:piece] = {}
        trial = extract_dates(trials[kee], matches)
        if invalid_month_day(trial)
          trials[kee] = {}
        end
      end
    }
    trials
  end

  # @param [Hash] trial of date strings
  # @return [Boolean]
  # check for as invalid day number per month for start and end date
  def self.invalid_month_day(trial)
    retval = false
    if trial[:start_date_day].to_i > 31 or trial[:end_date_day].to_i > 31
      retval = true
    end
    if trial[:start_date_day].to_i < 1 or (trial[:end_date_day].to_i < 1 and !trial[:end_date_day].blank?)
      retval = true
    end
    if trial[:start_date_month].to_i > 12 or trial[:end_date_month].to_i > 12
      retval = true
    end
    if trial[:start_date_month].to_i < 1 or (trial[:end_date_month].to_i < 1 and !trial[:end_date_month].blank?)
      retval = true
    end
    retval
  end

  # rubocop:disable Metrics/MethodLength
  # @param [Hash] trial
  # @param [Array] match_data of Regex results
  # @return [Hash]
  def self.extract_dates(trial, match_data)
    end_date_year, end_date_month, end_date_day = 0, 0, 0
    case trial[:method].downcase.to_sym
      when :month_dd_yyyy_2
        start_date_year = 3
        start_date_month = 1
        start_date_day = 2
        end_date_year = 6
        end_date_month = 4
        end_date_day = 5
      when :dd_month_yyyy_2
        start_date_year = 3
        start_date_month = 2
        start_date_day = 1
        end_date_year = 6
        end_date_month = 5
        end_date_day = 4
      when :mm_dd_yyyy_2
        start_date_year = 3
        start_date_month = 1
        start_date_day = 2
        end_date_year = 6
        end_date_month = 4
        end_date_day = 5
      when :month_dd_month_dd_yyyy
        start_date_year = 5
        start_date_month = 1
        start_date_day = 2
        end_date_year = 5
        end_date_month = 3
        end_date_day = 4
      when :dd_month_dd_month_yyyy
        start_date_year = 5
        start_date_month = 2
        start_date_day = 1
        end_date_year = 5
        end_date_month = 4
        end_date_day = 3
      when :dd_mm_dd_mm_yyyy
        start_date_year = 5
        start_date_month = 2
        start_date_day = 1
        end_date_year = 5
        end_date_month = 4
        end_date_day = 3
      when :mm_dd_mm_dd_yyyy
        start_date_year = 5
        start_date_month = 1
        start_date_day = 2
        end_date_year = 5
        end_date_month = 3
        end_date_day = 4
      when :month_dd_dd_yyyy
        start_date_year = 4
        start_date_month = 1
        start_date_day = 2
        end_date_year = 4
        end_date_month = 1
        end_date_day = 3
      when :dd_dd_month_yyyy
        start_date_year = 4
        start_date_month = 3
        start_date_day = 1
        end_date_year = 4
        end_date_month = 3
        end_date_day = 2
      when :mm_dd_dd_yyyy
        start_date_year = 4
        start_date_month = 1
        start_date_day = 2
        end_date_year = 4
        end_date_month = 1
        end_date_day = 3
      when :month_dd_yyy
        start_date_year = 3
        start_date_month = 1
        start_date_day = 2
        if match_data[1]
          end_date_year = 3
          end_date_month = 1
          end_date_day = 2
        end
      when :dd_month_yyy # done for yyyy
        start_date_year = 3
        start_date_month = 2
        start_date_day = 1
        if match_data[1]
          end_date_year = 3
          end_date_month = 2
          end_date_day = 1
        end
      when :mm_dd_yyyy
        start_date_year = 3
        start_date_month = 1
        start_date_day = 2
        if match_data[1]
          end_date_year = 3
          end_date_month = 1
          end_date_day = 2
        end
      when :mm_dd_yy
        start_date_year = 3
        start_date_month = 1
        start_date_day = 2
        if match_data[1]
          end_date_year = 3
          end_date_month = 1
          end_date_day = 2
        end
      when :dd_mm_yy
        start_date_year = 3
        start_date_month = 2
        start_date_day = 1
        if match_data[1]
          end_date_year = 3
          end_date_month = 2
          end_date_day = 1
        end
      when :yyyy_mm_dd
        start_date_year = 1
        start_date_month = 2
        start_date_day = 3
        if match_data[1]
          end_date_year = 1
          end_date_month = 2
          end_date_day = 3
        end
      when :yyy_mm_dd
        start_date_year = 1
        start_date_month = 2
        start_date_day = 3
        if match_data[1]
          end_date_year = 1
          end_date_month = 2
          end_date_day = 3
        end
      when :yyyy_month_dd
        start_date_year = 1
        start_date_month = 2
        start_date_day = 3
        if match_data[1]
          end_date_year = 1
          end_date_month = 2
          end_date_day = 3
        end
      when :yyyy_mm_dd_mm_dd
        start_date_year = 1
        start_date_month = 2
        start_date_day = 3
        end_date_year = 1
        end_date_month = 4
        end_date_day = 5
      when :yyyy_month_dd_month_dd
        start_date_year = 1
        start_date_month = 2
        start_date_day = 3
        end_date_year = 1
        end_date_month = 4
        end_date_day = 5
    end
    trial[:piece][0] = match_data[0][0]
    trial[:start_date_year] = fix_2_digit_year(match_data[0][start_date_year])
    trial[:start_date_month] = month_index(match_data[0][start_date_month]).to_s
    trial[:start_date_day] = match_data[0][start_date_day]
    trial[:end_date_year] = '' #  match_data[3]
    trial[:end_date_month] = '' #  month_index(match_data[2]).to_s
    trial[:end_date_day] = '' #  match_data[1]
    which_data = 0
    unless match_data[1].blank?
      which_data = 1
    end
    trial[:start_date] = trial[:start_date_year] + ' ' + trial[:start_date_month] + ' ' + trial[:start_date_day]
    trial[:end_date] = ''

    if (end_date_year > 0)
      trial[:piece][1] = match_data[which_data][0] unless which_data == 0
      trial[:end_date_year] = fix_2_digit_year(match_data[which_data][end_date_year])
      trial[:end_date_month] = month_index(match_data[which_data][end_date_month]).to_s
      trial[:end_date_day] = match_data[which_data][end_date_day]
      trial[:end_date] = trial[:end_date_year] + ' ' + trial[:end_date_month] + ' ' + trial[:end_date_day]
    end
    trial
  end

  # @return [Hash]
  # date from the label parsed to elements
  def self.date_regex_from_verbatim_label(text)
    return nil if text.blank?
    text = ' ' + text.downcase.squish + ' '

    date = {}
    # June 27 1946 - July 1 1947
    if matchdata1 = text.match(/\W(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?[-\s,\/]\s?(\d\d?)[\.;,]?[-\s\.,\/](\d{4}|['´`ʹʼˊ]?\s?\d{2})\s?[-–—]\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?[-\s,\/]\s?(\d\d?)[\.;,]?[-\s,\/]\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[2]
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[3]
      date[:end_date_day]  = matchdata1[5]
      date[:end_date_month] = matchdata1[4]
      date[:end_date_year] = matchdata1[6]
      # 27 June 1946 - 1 July 1947
    elsif matchdata1 = text.match(/\W(\d\d?)[\.,\/-]?\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?[\s,\/-]?\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\s?[-–—]\s?(\d\d?)[\.,\/-]?\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?[\s,\/-]?\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[1]
      date[:start_date_month] = matchdata1[2]
      date[:start_date_year] = matchdata1[3]
      date[:end_date_day]  = matchdata1[4]
      date[:end_date_month] = matchdata1[5]
      date[:end_date_year] = matchdata1[6]
      # 5 27 1946 - 6 1 1947
    elsif matchdata1 = text.match(/\W(\d\d?)[\s,\.\/]\s?(\d\d?)[\.,]?[\s\.,\/](\d{4}|'?\d{2})\s?[-–—]\s?(\d\d?)[\s,\.\/]\s?(\d\d?)[\.,]?[\s,\/]\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[2]
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[3]
      date[:end_date_day]  = matchdata1[5]
      date[:end_date_month] = matchdata1[4]
      date[:end_date_year] = matchdata1[6]
      # June 27 - July 1 1947
    elsif matchdata1 = text.match(/\W(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?[-–—\s,\/]?\s?(\d\d?)\s?[-–—]\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?[-–—\s,\/]?\s?(\d\d?)[-–—\s\.;,\/]\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[2]
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[5]
      date[:end_date_day]  = matchdata1[4]
      date[:end_date_month] = matchdata1[3]
      date[:end_date_year] = matchdata1[5]
      # 27 June - 1 July 1947
    elsif matchdata1 = text.match(/\W(\d\d?)[-–—\.\/,]?\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?\s?[-–—]\s?(\d\d?)[-–—\.\/,]?\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?[-–—,\/]?\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[1]
      date[:start_date_month] = matchdata1[2]
      date[:start_date_year] = matchdata1[5]
      date[:end_date_day]  = matchdata1[3]
      date[:end_date_month] = matchdata1[4]
      date[:end_date_year] = matchdata1[5]
      # 5 27 - 6 1 1947
    elsif matchdata1 = text.match(/\W(\d\d?)[\s\.,\/]\s?(\d\d?)\s?[-–—]\s?(\d\d?)[\s\.,\/]\s?(\d\d?)[\s\.,\/]\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[2]
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[5]
      date[:end_date_day]  = matchdata1[4]
      date[:end_date_month] = matchdata1[3]
      date[:end_date_year] = matchdata1[5]
      # June 27-29 1947
    elsif matchdata1 = text.match(/\W(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?[-–—\s\/,]?(\d\d?)\s?[-–—\+]\s?(\d\d?)[\.;,]?[-\s\.–,\/]\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[2]
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[4]
      date[:end_date_day]  = matchdata1[3]
      date[:end_date_month] = matchdata1[1]
      date[:end_date_year] = matchdata1[4]
      # 27-29 June 1947
    elsif matchdata1 = text.match(/\W(\d\d?)\s?[-–—\+]\s?(\d\d?)[\s\.,\/-]\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?[-–—\s\/,]?\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[1]
      date[:start_date_month] = matchdata1[3]
      date[:start_date_year] = matchdata1[4]
      date[:end_date_day]  = matchdata1[2]
      date[:end_date_month] = matchdata1[3]
      date[:end_date_year] = matchdata1[4]
      #=begin
      # 27-29 12 1947 #### watch for false positives
    elsif matchdata1 = text.match(/\W(\d\d?)\s?[-–—\+]\s?(\d\d?)[\s\.,\/]\s?(\d\d)\.?[\s\/,\.](\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[1]
      date[:start_date_month] = matchdata1[3]
      date[:start_date_year] = matchdata1[4]
      date[:end_date_day]  = matchdata1[2]
      date[:end_date_month] = matchdata1[3]
      date[:end_date_year] = matchdata1[4]
      #=end
      # 12 27-29 1947
    elsif matchdata1 = text.match(/\W(\d\d)[\s\.,\/]\s?(\d\d?)\s?[-–—\+]\s?(\d\d?)[\.,]?[\s,\/](\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[2]
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[4]
      date[:end_date_day]  = matchdata1[3]
      date[:end_date_month] = matchdata1[1]
      date[:end_date_year] = matchdata1[4]
      # June - July 1947
    elsif matchdata1 = text.match(/\W(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?\s?[-–—]\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xi|xii|x|iii|ii|i)\.?[-–—,\/]?\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[3]
      date[:end_date_month] = matchdata1[2]
      date[:end_date_year] = matchdata1[3]
      # Jun 29 1947     Jun 29, 1947    June 29, 1947    VI-29-1947   X.25.2000   Jun 29, '47   June 29, '47    VI-4-08
    elsif matchdata1 = text.match(/\W(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)\.?\s?[-–—_,\/]?\s?(\d\d?)[\.;,]?\s?[-–—_\/\.',\s]\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[2]
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[3]
      # 29 Jun 1947   29 June 1947   2 June, 1983   29 VI 1947   29-VI-1947   25.X.2000  25X2000  29 June '47   29 Jun '47
    elsif matchdata1 = text.match(/\W(\d\d?)\s?[-–—_\.,\/]?\s?(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)[\.,\/]?\s?[-–—,]?\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[1]
      date[:start_date_month] = matchdata1[2]
      date[:start_date_year] = matchdata1[3]
      # 6/29/1947    6-29-1947    6-15 1985    10.25 2000    7.10.1994
    elsif matchdata1 = text.match(/\W(\d\d?)[-–—_\.,\/\s]\s?(\d\d?)[-–—_\.,\/\s]\s?(\d{4})\W/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[2]
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[3]
      # 6/29/47    6/29/'47    7.10.94    5-17-97
    elsif matchdata1 = text.match(/\W(\d\d?)[-–—_\.,\/\s]\s?(\d\d?)[-–—_\.,\/\s]\s?(['´`ʹʼˊ]?\s?\d{2})\W/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_day] = matchdata1[2]
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[3]
      # Jun 1947   June 1947   VI 1947   VI-1947   X.2000
    elsif matchdata1 = text.match(/\W(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|sept|oct|nov|dec|viii|vii|iv|vi|v|ix|xii|xi|x|iii|ii|i)[\.,]?\s?[-–—,]?\s?(\d{4}|['´`ʹʼˊ]?\s?\d{2})\D/)
      date[:verbatim_date] = matchdata1[0].strip
      date[:start_date_month] = matchdata1[1]
      date[:start_date_year] = matchdata1[2]
    end

    return {} if date[:verbatim_date].blank?

    date[:verbatim_date] = date[:verbatim_date][0..-2] if date[:verbatim_date] =~ /[;,:\)\.\/]$/

    date[:start_date_month] = date[:start_date_month].gsub('january', '1')
        .gsub('february', '2')
        .gsub('march', '3')
        .gsub('april', '4')
        .gsub('may', '5')
        .gsub('june', '6')
        .gsub('july', '7')
        .gsub('august', '8')
        .gsub('september', '9')
        .gsub('october', '10')
        .gsub('november', '11')
        .gsub('december', '12')
        .gsub('jan', '1')
        .gsub('feb', '2')
        .gsub('mar', '3')
        .gsub('apr', '4')
        .gsub('sept', '9')
        .gsub('jun', '6')
        .gsub('jul', '7')
        .gsub('aug', '8')
        .gsub('sep', '9')
        .gsub('oct', '10')
        .gsub('nov', '11')
        .gsub('dec', '12')
        .gsub('xii', '12')
        .gsub('xi', '11')
        .gsub('ix', '9')
        .gsub('x', '10')
        .gsub('viii', '8')
        .gsub('vii', '7')
        .gsub('vi', '6')
        .gsub('iv', '4')
        .gsub('v', '5')
        .gsub('iii', '3')
        .gsub('ii', '2')
        .gsub('i', '1') if date[:start_date_month]

    date[:end_date_month] = date[:end_date_month].gsub('january', '1')
        .gsub('february', '2')
        .gsub('march', '3')
        .gsub('april', '4')
        .gsub('may', '5')
        .gsub('june', '6')
        .gsub('july', '7')
        .gsub('august', '8')
        .gsub('september', '9')
        .gsub('october', '10')
        .gsub('november', '11')
        .gsub('december', '12')
        .gsub('jan', '1')
        .gsub('feb', '2')
        .gsub('mar', '3')
        .gsub('apr', '4')
        .gsub('sept', '9')
        .gsub('jun', '6')
        .gsub('jul', '7')
        .gsub('aug', '8')
        .gsub('sep', '9')
        .gsub('oct', '10')
        .gsub('nov', '11')
        .gsub('dec', '12')
        .gsub('xii', '12')
        .gsub('xi', '11')
        .gsub('ix', '9')
        .gsub('x', '10')
        .gsub('viii', '8')
        .gsub('vii', '7')
        .gsub('vi', '6')
        .gsub('iv', '4')
        .gsub('v', '5')
        .gsub('iii', '3')
        .gsub('ii', '2')
        .gsub('i', '1') if date[:end_date_month]

    date[:verbatim_date] = date[:verbatim_date].gsub('january', 'January')
        .gsub('february', 'February')
        .gsub('march', 'March')
        .gsub('april', 'April')
        .gsub('may', 'May')
        .gsub('june', 'June')
        .gsub('july', 'July')
        .gsub('august', 'August')
        .gsub('september', 'September')
        .gsub('october', 'October')
        .gsub('november', 'November')
        .gsub('december', 'December')
        .gsub('xii', 'XII')
        .gsub('xi', 'XI')
        .gsub('ix', 'IX')
        .gsub('x', 'X')
        .gsub('viii', 'VIII')
        .gsub('vii', 'VII')
        .gsub('vi', 'VI')
        .gsub('iv', 'IV')
        .gsub(' v', ' V')  # space needed not to replace in 'November'
        .gsub('iii', 'III')
        .gsub('ii', 'II')
        .gsub(' i', ' I') if date[:verbatim_date] # space needed not to replace in 'April'

    if date[:start_date_year] && date[:start_date_year].length >=2 && date[:start_date_year].length < 4
      y = date[:start_date_year].last(2)
      if y.to_i >= 90
        y = '18' + y
      else
        y = '19' + y
      end
      date[:start_date_year] = y
    end
    if date[:end_date_year] && date[:end_date_year].length >=2 && date[:end_date_year].length < 4
      y = date[:end_date_year].last(2)
      if y.to_i >= 90
        y = '18' + y
      else
        y = '19' + y
      end
      date[:end_date_year] = y
    end

    if Date.valid_date?(date[:start_date_year].to_i, date[:start_date_month].to_i, date[:start_date_day].to_i) &&
        Date.parse(date[:start_date_year].to_s + '-' + date[:start_date_month].to_s + '-' + date[:start_date_day].to_s) <= Date.today &&
        date[:start_date_year].to_s + '-' + date[:start_date_month].to_s + '-' + date[:start_date_day].to_s > '1700-01-01'
      if date[:end_date_year] && Date.valid_date?(date[:end_date_year].to_i, date[:end_date_month].to_i, date[:end_date_day].to_i) &&
          Date.parse(date[:end_date_year].to_s + '-' + date[:end_date_month].to_s + '-' + date[:end_date_day].to_s) <= Date.today &&
          Date.parse(date[:end_date_year].to_s + '-' + date[:end_date_month].to_s + '-' + date[:end_date_day].to_s) >= Date.parse(date[:start_date_year].to_s + '-' + date[:start_date_month].to_s + '-' + date[:start_date_day].to_s) &&
          date[:end_date_year].to_s + '-' + date[:end_date_month].to_s + '-' + date[:end_date_day].to_s > '1700-01-01'
        return date
      elsif date[:end_date_year].nil?
        return date
      else
        return {}
      end
    elsif date[:start_date_day].nil? &&
        Date.valid_date?(date[:start_date_year].to_i, date[:start_date_month].to_i, 1) &&
        Date.parse(date[:start_date_year].to_s + '-' + date[:start_date_month].to_s + '-1') <= Date.today &&
        date[:start_date_year].to_s + '-' + date[:start_date_month].to_s + '-1' > '1700-01-01'
      if date[:end_date_day].nil? && date[:end_date_year]
          Date.valid_date?(date[:end_date_year].to_i, date[:end_date_month].to_i, 1) &&
          Date.parse(date[:end_date_year].to_s + '-' + date[:end_date_month].to_s + '-1') <= Date.today &&
          Date.parse(date[:end_date_year].to_s + '-' + date[:end_date_month].to_s + '-1') >= Date.parse(date[:start_date_year].to_s + '-' + date[:start_date_month].to_s + '-1') &&
          date[:end_date_year].to_s + '-' + date[:end_date_month].to_s + '-1' > '1700-01-01'
        return date
      elsif date[:end_date_year].nil?
        return date
      else
        return {}
      end
    else
      return {}
    end

  end

end
