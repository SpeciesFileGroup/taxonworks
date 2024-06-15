# Polygon definition...
#
class GeographicItem::Polygon < GeographicItem
  validates_presence_of :polygon

  # @return [Array] arrays of points
  def to_a
    polygon_to_a(self.polygon)
  end

  # @return [RGeo::Point] first point in the polygon
  def st_start_point
    geo_object.exterior_ring.point_n(0)
  end

  # @return [Hash]
  def rendering_hash
    polygon_to_hash(self.polygon)
  end

  def keystone_error_box
    geo_object
  end
end
