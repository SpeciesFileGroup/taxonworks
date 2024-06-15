# Multi point definition...
#
class GeographicItem::MultiPoint < GeographicItem
  validates_presence_of :multi_point

  # @return [Array] arrays of points
  def to_a
    multi_point_to_a(self.multi_point)
  end

  # @return [RGeo::Point] first point
  def st_start_point
    geo_object[0]
  end

  # @return [Hash]
  def rendering_hash
    multi_point_to_hash(self.multi_point)
  end

end
