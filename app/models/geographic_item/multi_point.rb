class GeographicItem::MultiPoint < GeographicItem 
  SHAPE_COLUMN = :multi_point
  validates_presence_of :multi_point
end
