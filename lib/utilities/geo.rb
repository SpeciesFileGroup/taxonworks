=begin
To add a new (discovered) symbol:
  1) To find the Unicode string for any character, use Utilities::Geo.uni_string('c') (remove the first '\').
  2) Add the Unicode string (i.e, "\uNNNN") to SPECIAL_LATLONG_SYMBOLS (below), selecting either degrees
      (starting with 'do*'), or tickmarks (starting at "'").
  3) Add the Unicode to the proper section in the regexp in the corresponding section (degrees, minutes, or seconds).
      NB: all the minutes symbols are duplicated in the seconds section because sometimes two successive tickmarks
          (for minutes) are used for seconds.
=end
# degree symbols, in addition to 'd', 'o', and '*'
# \u00b0  "°"  \u00ba  "º"  \u02da  "˚"  \u030a  "?"  \u221e "∞"  \u222b "∫"

# tick symbols, in addition to "'" ("\u0027""), and '"' ("\u0022")
# \u00a5  "¥"  \u00b4  "´"
# \u02B9  "ʹ"  \u02BA  "ʺ"  \u02BB  "ʻ"  \u02BC  "ʼ"  \u02CA "ˊ"
# \u02EE  "ˮ"  \u2032  "′"  \u2033  "″"

SPECIAL_LATLONG_SYMBOLS = "do*\u00b0\u00ba\u02DA\u030a\u221e\u222b\u0027\u00b4\u02B9\u02BA\u02BB\u02BC\u02CA\u02EE\u2032\u2033\u0022"
# DMS_REGEX = "(?<degrees>-*\d+)[do*\u00b0\u00ba\u02DA\u030a\u221e\u222b]\s*(?<minutes>\d+\.*\d*)[\u0027\u00a5\u00b4\u02b9\u02bb\u02bc\u02ca\u2032]*\s*((?<seconds>\d+\.*\d*)[\u0027\u00a5\u00b4\u02b9\u02ba\u02bb\u02bc\u02ca\u02ee\u2032\u2033\u0022]+)*"

module Utilities::Geo
  # http://en.wikiversity.org/wiki/Geographic_coordinate_conversion
  # http://stackoverflow.com/questions/1774985/converting-degree-minutes-seconds-to-decimal-degrees
  # http://stackoverflow.com/questions/1774781/how-do-i-convert-coordinates-to-google-friendly-coordinates

  class ConvertToDecimalDegrees

    attr_reader(:dd, :dms)

    def initialize(coordinate)
      @dms = coordinate
      @dd  = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(coordinate)
    end

  end

  # 42∞5'18.1"S88∞11'43.3"W
  # S42∞5'18.1"W88∞11'43.3"
  # S42∞5.18'W88∞11.43'
  # 42∞5.18'S88∞11.43'W
  # S42.18∞W88.34∞
  # 42.18∞S88.43∞W
  # -12.263, 49.398
  #
  # 42:5:18.1N
  # 88:11:43.3W

  # no limit test, unless there is a letter included
  def self.degrees_minutes_seconds_to_decimal_degrees(dms_in)
    match_string = nil
    no_point      = false
    degrees       = 0.0; minutes = 0.0; seconds = 0.0

    # make SURE it is a string! Watch out for dms_in == -10
    dms_in        = dms_in.to_s
    dms           = dms_in.dup.upcase
    dms =~ /[NSEW]/i
    cardinal = $~.to_s
    # return "#{dms}: Too many letters (#{cardinal})" if cardinal.length > 1
    # return nil if cardinal.length > 1
    dms      = dms.gsub!(cardinal, '').strip.downcase

    if dms.include? '.'
      if dms.include? ':' # might be '42:5.1'
        /(?<degrees>-*\d+):(?<minutes>\d+\.*\d*)(:(?<seconds>\d+\.*\d*))*/ =~ dms
        match_string = $&
      else
        # this will get over-ridden if the next regex matches
        /(?<degrees>-*\d+\.\d+)/ =~ dms
        match_string = $&
      end
    else
      no_point = true
    end

    # >40°26′46″< >40°26′46″<
    dms.each_char { |c|
      if SPECIAL_LATLONG_SYMBOLS.include?(c)
        /(?<degrees>-*\d+)[do*\u00b0\u00ba\u02DA\u030a\u221e\u222b]\s*(?<minutes>\d+\.*\d*)['\u00a5\u00b4\u02b9\u02bb\u02bc\u02ca\u2032]*\s*((?<seconds>\d+\.*\d*)['\u00a5\u00b4\u02b9\u02ba\u02bb\u02bc\u02ca\u02ee\u2032\u2033"]+)*/ =~ dms
        match_string = $&
        # /#{DMS_REGEX}/ =~ dms
        break
      end
    }
    if match_string.nil? and no_point
      # seems like it is an orphaned number with no decimal point, i.e., -10
      degrees = dms.to_f
    end

    # @match_string = $&
    degrees = degrees.to_f
    case cardinal
      when 'W', 'S'
        sign = -1.0
      else
        sign = 1.0
    end
    if degrees < 0
      sign    *= -1
      degrees *= -1.0
    end
    frac = ((minutes.to_f * 60.0) + seconds.to_f) / 3600.0
    dd   = (degrees + frac) * sign
    case cardinal
      when 'N', 'S'
        limit = 90.0
      else
        limit = 180.0
    end
    # return "#{dms}: Out of range (#{dd})" if dd.abs > limit
    if dd.abs > limit or dd == 0.0
      return nil
    end
    dd.round(6).to_s
  end

  def uni_string(char)
    '\\' + sprintf("u%04X", char.ord)
  end

  def self.nearby_from_params(params)
    nearby_distance = params['nearby_distance'].to_i
    if nearby_distance == 0
      nearby_distance = CollectingEvent::NEARBY_DISTANCE
    end

    case nearby_distance.to_s.length
      when 1..2
        decade = 10
      when 3
        decade = 100
      when 4
        decade = 1000
      when 5
        decade = 10000
      when 6
        decade = 100000
      when 7
        decade = 1000000
      when 8
        decade = 10000000
      else
        decade = 10
    end
    digit = (nearby_distance.to_f / decade.to_f).round

    case digit
      when 0..1
        digit = 1
      when 2
        digit = 2
      when 3..5
        digit = 5
      when 6..10
        digit  = 1
        decade *= 10
    end

    params['digit1'] = digit.to_s
    params['digit2'] = decade.to_s
    nearby_distance  = digit * decade
  end

end
