# Geography definition...
#
class GeographicItem::Geography < GeographicItem
  validates_presence_of :geography

  # TODO: to_a, st_start_point, others?
end
