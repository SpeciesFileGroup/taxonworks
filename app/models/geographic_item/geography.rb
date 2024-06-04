# Geography definition...
#
class GeographicItem::Geography < GeographicItem
  SHAPE_COLUMN = :geography
  validates_presence_of :geography

  def type
    "GeographicItem::#{geography.geometry_type.type_name}"
  end
end
