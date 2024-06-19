# Geography definition...
#
class GeographicItem::Geography < GeographicItem
  validates_presence_of :geography

  # DEPRECATED
  # def st_start_point
  # end

  # DEPRECATED
  # def rendering_hash
  # end

  # DEPRECATED
  # def to_hash
  # end
end
