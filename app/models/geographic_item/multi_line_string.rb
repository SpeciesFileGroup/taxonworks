# Multi line string definition...
#
class GeographicItem::MultiLineString < GeographicItem
  validates_presence_of :multi_line_string

  # @return [Array] arrays of points
  def to_a
    multi_line_string_to_a(self.multi_line_string)
  end

  # @return [RGeo::Point] first point in the first line_string
  def st_start_point
    geo_object[0].point_n(0)
  end

  # @return [Hash]
  def rendering_hash
    multi_line_string_to_hash(self.multi_line_string)
  end

end
