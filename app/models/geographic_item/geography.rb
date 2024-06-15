# Geography definition...
#
class GeographicItem::Geography < GeographicItem
  SHAPE_COLUMN = :geography
  validates_presence_of :geography
end
