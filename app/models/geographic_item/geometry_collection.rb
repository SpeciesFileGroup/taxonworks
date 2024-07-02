# Geometry collection definition...
#
class GeographicItem::GeometryCollection < GeographicItem
  validates_presence_of :geometry_collection

  # @return [GeoJSON Feature]
  # the shape as a Feature/Feature Collection
  def to_geo_json_feature
    self.geometry = rgeo_to_geo_json
    super
  end

end
