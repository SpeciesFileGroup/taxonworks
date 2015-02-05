class GeographicItem::MultiPolygon < GeographicItem 
 SHAPE_COLUMN = :multi_polygon
 validates_presence_of :multi_polygon

 def to_a
   multi_polygon_to_a(self.multi_polygon)
 end

 def st_start_point
    geo_object[0].exterior_ring.point_n(0)
 end

end
