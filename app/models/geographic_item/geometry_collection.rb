# Geometry collection definition...
#
class GeographicItem::GeometryCollection < GeographicItem
  validates_presence_of :geometry_collection

end
