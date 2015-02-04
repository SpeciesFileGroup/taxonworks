class GeographicItem::MultiPolygon < GeographicItem 
 SHAPE_COLUMN = :multi_polygon
 validates_presence_of :multi_polygon
end
