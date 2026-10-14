# An Image or Depiction placed on a Layout::LightTable.
#
# x, y, width, height: pixels, see CompositionItem's Coordinate system
# z: stacking order, higher is in front
# zoom: scale factor, 1.0 is 100%
# rotation_z: degrees, clockwise (as CSS rotate())
#
class LayoutItem::LightTableItem < LayoutItem
  include Shared::Render::DepictionItem
  include Shared::Render::ImageItem

  validates_presence_of :composition_item_object
  validate :composition_is_light_table

  protected

  def composition_is_light_table
    if composition && !composition.is_a?(Layout::LightTable)
      errors.add(:composition, 'must be a light table')
    end
  end

end
