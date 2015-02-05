class GeographicItem::Polygon < GeographicItem 
  SHAPE_COLUMN = :polygon
  validates_presence_of :polygon

  def to_a
    polygon_to_a(self.polygon)
  end

  def st_start_point
    geo_object.exterior_ring.point_n(0)
  end

  def rendering_hash
    polygon_to_hash(self.polygon)
  end
end
