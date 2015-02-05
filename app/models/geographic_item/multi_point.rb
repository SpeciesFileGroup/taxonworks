class GeographicItem::MultiPoint < GeographicItem 
  SHAPE_COLUMN = :multi_point
  validates_presence_of :multi_point
  def to_a
    multi_point_to_a(self.multi_point)
  end

  def st_start_point
    geo_object[0]
  end

  def rendering_hash
    multi_point_to_hash(self.multi_point)
  end
end
