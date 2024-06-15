# Line string definition...
#
class GeographicItem::LineString < GeographicItem
  validates_presence_of :line_string

  # @return [Array] arrays of points
  def to_a
    line_string_to_a(self.line_string)
  end

  # @return [RGeo::Point] first point in the line_string
  def st_start_point
    geo_object.point_n(0)
  end

  # @return [Hash]
  def rendering_hash
    line_string_to_hash(self.line_string)
  end

end
