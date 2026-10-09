# An Image placed in a Layout.
#
# x, y, width, height: pixels, in the Layout's coordinate space
# z: stacking order, higher is in front
# zoom: scale factor, 1.0 is 100%
# svg_view_box / svg_clip: crop, sensu Depiction
#
class LayoutItem::ImageItem < LayoutItem

  validates_presence_of :composition_item_object

  def self.composition_item_object_permitted?(klass)
    klass <= Image
  end

end
