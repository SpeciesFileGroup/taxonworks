# A Georeference derived from a Google map.
class Georeference::GoogleMap < Georeference

  # coordinates is an Array of Stings of [longitude, latitude]
  def make_geographic_item(geo_type, shape)
    # self.geographic_item = GeographicItem.new(point: Georeference::FACTORY.point(coordinates[0], coordinates[1]))
  end

end
