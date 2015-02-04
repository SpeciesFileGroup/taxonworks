class GeographicItem::MultiLineString < GeographicItem 
  SHAPE_COLUMN = :multi_line_string
  validates_presence_of :multi_line_string
end
