class GeographicItem::LineString < GeographicItem 
   SHAPE_COLUMN = :line_string
   validates_presence_of :line_string
end
