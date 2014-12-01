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
    dms = dms_in.dup.upcase
    degrees = 0.0; minutes = 0.0; seconds = 0.0
    dms =~ /[NSEW]/i
    cardinal = $~.to_s.upcase
    # return "#{dms}: Too many letters (#{cardinal})" if cardinal.length > 1
    return nil if cardinal.length > 1
    dms = dms.gsub!(cardinal, '').strip

    if dms.include? '.'
      unless dms.include? ':'
        /(?<degrees>-*\d+\.\d+)/ =~ dms
      end
    end

    if dms.include? ':'
      /(?<degrees>-*\d+):(?<minutes>\d+\.*\d*)(:(?<seconds>\d+\.*\d*))*/ =~ dms
    end
    # >40°26′46″< >40°26′46″<
    if dms.include?('D') or dms.include?('º') or dms.include?('°') or dms.include?('∞')
      /(?<degrees>-*\d+)[∞º°D]\s*(?<minutes>\d+\.*\d*)['′]*\s*((?<seconds>\d+\.*\d*)["″])*/ =~ dms
    end

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
    return nil if dd.abs > limit
    dd.round(6).to_s
  end
end
