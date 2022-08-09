module Utilities::Elevation


  class MethodFromLabel
    attr_reader(:verbatim_label, :date)

    # @param [String] label
    def initialize(label)
      @verbatim_label = label
      @collecting_method = Utilities::Elevation.elevation_regex_from_verbatim_label(text)
    end
  end

  def self.elevation_regex_from_verbatim_label(text)
    text = ' ' + text.downcase.squish + ' '
    elevation = {}

    if (matchdata1 = text.match(/\D(\d*,?\d+)\s?[-–]\s?(\d*,?\d+) ?(m|ft|feet|meters)\.?\W/))
      elevation[:verbatim_elevation] = matchdata1[0].strip
      elevation[:minimum_elevation] = matchdata1[1]
      elevation[:maximum_elevation] = matchdata1[2]
      elevation[:units] = matchdata1[3]
    elsif (matchdata1 = text.match(/\D(\d*,?\d+) ?(m|ft|feet|meters)\.?( ?(\+\/-|±) ?(\d+) ?(m|ft|feet|meters)?[. ]?)?\W/))
      elevation[:verbatim_elevation] = matchdata1[0].strip
      elevation[:minimum_elevation] = matchdata1[1]
      elevation[:units] = matchdata1[2]
      elevation[:elevation_precision] = matchdata1[5] if matchdata1[5]
    end

    if elevation[:units]
      elevation[:units] = elevation[:units].gsub('feet', 'ft')
                              .gsub('meters', 'm')
                              .gsub('.', '')
      elevation[:verbatim_elevation] = elevation[:verbatim_elevation][0..-2] if elevation[:verbatim_elevation] =~ /[;,:).\/]$/
      elevation[:minimum_elevation] = elevation[:minimum_elevation].gsub(',', '') if elevation[:minimum_elevation]
      elevation[:maximum_elevation] = elevation[:maximum_elevation].gsub(',', '') if elevation[:maximum_elevation]

      if elevation[:units].to_s == 'ft'
        convert_to_meters!(elevation, :minimum_elevation)
        convert_to_meters!(elevation, :maximum_elevation)
        convert_to_meters!(elevation, :elevation_precision)
        elevation[:units] = 'm'
      end
      return elevation
    else
      return {}
    end
  end

  private

  # Converts the value in a hash from feet to meters
  # @param [Hash] hsh
  # @param [Symbol] key
  def self.convert_to_meters!(hsh, key)
    hsh[key] = (hsh[key].to_f * 0.3048).round(2).to_s if hsh[key]
  end
end
