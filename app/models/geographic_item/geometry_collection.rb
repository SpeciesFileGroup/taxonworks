class GeographicItem::GeometryCollection < GeographicItem 
 SHAPE_COLUMN = :geometry_collection
 validates_presence_of :geometry_collection

 def st_start_point
   to_geo_json_1 =~ /(-{0,1}\d+\.{0,1}\d*),(-{0,1}\d+\.{0,1}\d*)/
   Georeference::FACTORY.point($1.to_f, $2.to_f, 0.0)
 end
end
