=begin
To add a new (discovered) symbol:
  1) Add the Unicode string (i.e, "\uNNNN") to SPECIAL_LATLONG_SYMBOLS (below), selecting either degrees
      (starting with 'do*'), or tickmarks (starting at "'")
  2) Add the Unicode to the proper section in the regexp in the corresponding section (degrees, minutes, or seconds).
      NB: all the minutes symbols are duplicated in the seconds section because sometimes two successive tickmarks
          (for minutes) are used for seconds
=end
# degree symbols, in addition to 'd', 'o', and '*'
# \u00b0  "°"  \u00ba  "º"  \u02da  "˚"  \u030a  "?"  \u221e "∞"  \u222b "∫"

# tick symbols, in addition to "'", and '"'
# \u00a5  "¥"  \u00b4  "´"
# \u02B9  "ʹ"  \u02BA  "ʺ"  \u02BB  "ʻ"  \u02BC  "ʼ"  \u02CA "ˊ"
# \u02EE  "ˮ"  \u2032  "′"  \u2033  "″"

SPECIAL_LATLONG_SYMBOLS = "do*\u00b0\u00ba\u02DA\u030a\u221e\u222b'\u00b4\u02B9\u02BA\u02BB\u02BC\u02CA\u02EE\u2032\u2033\""

module Utilities::Geo
  # http://en.wikiversity.org/wiki/Geographic_coordinate_conversion
  # http://stackoverflow.com/questions/1774985/converting-degree-minutes-seconds-to-decimal-degrees
  # http://stackoverflow.com/questions/1774781/how-do-i-convert-coordinates-to-google-friendly-coordinates

  class ConvertToDecimalDegrees

    def initialize(coordinate)
      # figure out what the DD is for this (single) coordinate
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
    dms     = dms_in.dup.upcase
    degrees = 0.0; minutes = 0.0; seconds = 0.0
    dms =~ /[NSEW]/i
    cardinal = $~.to_s.upcase
    # return "#{dms}: Too many letters (#{cardinal})" if cardinal.length > 1
    # return nil if cardinal.length > 1
    dms      = dms.gsub!(cardinal, '').strip.downcase

    if dms.include? '.'
      if dms.include? ':' # might be '42:5.1'
        /(?<degrees>-*\d+):(?<minutes>\d+\.*\d*)(:(?<seconds>\d+\.*\d*))*/ =~ dms
      else
        # this will get over-ridden if the next regex matchs
        /(?<degrees>-*\d+\.\d+)/ =~ dms
      end
    end

    # >40°26′46″< >40°26′46″<
    dms.each_char { |c|
      if SPECIAL_LATLONG_SYMBOLS.include?(c)
        /(?<degrees>-*\d+)[do*\u00b0\u00ba\u02DA\u030a\u221e\u222b]\s*(?<minutes>\d+\.*\d*)['\u00a5\u00b4\u02b9\u02bb\u02bc\u02ca\u2032]*\s*((?<seconds>\d+\.*\d*)['\u00a5\u00b4\u02b9\u02ba\u02bb\u02bc\u02ca\u02ee\u2032\u2033"]+)*/ =~ dms
        break
      end
    }

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

end
