# An Image placed in a Layout, e.g. one that depicts nothing yet. See
# LayoutItem::DepictionItem for an Image as it depicts something.
#
# x, y, width, height: pixels, see CompositionItem's Coordinate system
# z: stacking order, higher is in front
# zoom: scale factor, 1.0 is 100%
# rotation_z: degrees, clockwise (as CSS rotate())
# svg_view_box / svg_clip: crop, sensu Depiction
#
class LayoutItem::ImageItem < LayoutItem

  validates_presence_of :composition_item_object

  def self.composition_item_object_permitted?(klass)
    klass <= Image
  end

end
