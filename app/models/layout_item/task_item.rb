# A CollectionObject listed in a Layout::Task, in order (position, new
# items at the bottom). Coordinates (x, y, z, etc.) are unused.
#
class LayoutItem::TaskItem < LayoutItem
  include Shared::Render::CollectionObjectItem

  validates_presence_of :composition_item_object
  validates_uniqueness_of :composition_item_object_id,
    scope: [:composition_id, :composition_item_object_type],
    message: 'is already in this composition'
  validate :composition_is_task

  protected

  def composition_is_task
    if composition && !composition.is_a?(Layout::Task)
      errors.add(:composition, 'must be a Layout::Task')
    end
  end

end
