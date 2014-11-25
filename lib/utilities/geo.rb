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
  def self.degrees_minutes_seconds_to_decimal_degrees(dms)
    dms =~ /[nsew]/i
    dir = $~.to_s.upcase
    # return "#{dms}: Too many letters (#{dir})" if dir.length > 1
    return nil if dir.length > 1
    dms.gsub!(dir, '')
    pieces = dms.split(':')
    degrees = pieces[0].to_f
    case dir
      when 'W', 'S'
        sign = -1.0
      else
        sign = 1.0
    end
    if degrees < 0
      sign *= -1
      degrees *= -1.0
    end
    seconds = (pieces[1].to_f * 60.0) + pieces[2].to_f
    frac = seconds / 3600.0
    dd = (degrees + frac) * sign
    case dir
      when 'N', 'S'
        limit = 90.0
      else
        limit = 180.0
    end
    # return "#{dms}: Out of range (#{dd})" if dd.abs > limit
    return nil if dd.abs > limit
    dd.to_s
  end


end
