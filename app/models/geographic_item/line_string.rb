class GeographicItem::LineString < GeographicItem 
  SHAPE_COLUMN = :line_string
  validates_presence_of :line_string

  def to_a
    line_string_to_a(self.line_string)
  end

  def st_start_point
    geo_object.point_n(0)
  end

end
