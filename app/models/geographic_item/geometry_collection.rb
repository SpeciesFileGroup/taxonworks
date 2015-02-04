class GeographicItem::GeometryCollection < GeographicItem 
 SHAPE_COLUMN = :geometry_collection
 validates_presence_of :geometry_collection
end
