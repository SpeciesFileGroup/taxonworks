# A Depiction placed in a Layout, i.e. an Image as it depicts something
# (an Otu, a CollectionObject, etc.). See LayoutItem::ImageItem for an
# Image that depicts nothing yet.
#
# x, y, width, height: pixels, see CompositionItem's Coordinate system
# z: stacking order, higher is in front
# zoom: scale factor, 1.0 is 100%
# rotation_z: degrees, clockwise (as CSS rotate())
# svg_view_box / svg_clip: crop for this Layout only; when present it
#   replaces the Depiction's own crop, when nil the Depiction's is used
#
class LayoutItem::DepictionItem < LayoutItem

  validates_presence_of :composition_item_object

  def self.composition_item_object_permitted?(klass)
    klass <= Depiction
  end

end
