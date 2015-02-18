class GeographicItem::MultiPolygon < GeographicItem 
 SHAPE_COLUMN = :multi_polygon
 validates_presence_of :multi_polygon

 # @return [Array] of Arrays of points
 def to_a
   multi_polygon_to_a(self.multi_polygon)
 end

 # @return [RGeo::Point] first point in first polygon
 def st_start_point
    geo_object[0].exterior_ring.point_n(0)
 end

 # @return [Hash]
 def rendering_hash
   multi_polygon_to_hash(self.multi_polygon)
 end

end
