class GeographicItem::Polygon < GeographicItem 
 SHAPE_COLUMN = :polygon
 validates_presence_of :polygon
end
