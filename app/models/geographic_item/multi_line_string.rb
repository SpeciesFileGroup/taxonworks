class GeographicItem::MultiLineString < GeographicItem 
  SHAPE_COLUMN = :multi_line_string
  validates_presence_of :multi_line_string

  def to_a
    multi_line_string_to_a(self.multi_line_string)
  end

  def st_start_point
    geo_object[0].point_n(0)
  end

  def rendering_hash
    multi_line_string_to_hash(self.multi_line_string)
  end

end
