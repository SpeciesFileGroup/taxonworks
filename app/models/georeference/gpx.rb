# A Georeference derived from a GPX JSON object.
#
class Georeference::GPX < Georeference

  def initialize(request_params)
    super

  end

  # coordinates is an Array of Stings of [longitude, latitude]
  # @param [Symbol] geo_type
  # @param [Ignored] shape
  def make_geographic_item(geo_type, shape)
    case geo_type
      when :line_string
      when :point

    end
    self.geographic_item = GeographicItem.new(point: Gis::FACTORY.point(coordinates[0], coordinates[1]))
  end

  #

end
