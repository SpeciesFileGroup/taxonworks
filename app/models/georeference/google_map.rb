# A Georeference derived from a Google map.
#
class Georeference::GoogleMap < Georeference

  # coordinates is an Array of Stings of [longitude, latitude]
  # @param [Ignored] geo_type
  # @param [Ignored] shape
  def make_geographic_item(geo_type, shape)
    # self.geographic_item = GeographicItem.new(point: Gis::FACTORY.point(coordinates[0], coordinates[1]))
  end

end
