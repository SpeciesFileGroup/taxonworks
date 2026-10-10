# A LayoutItem places a specific thing in a Layout.
#
# Only a LayoutItem::GroupItem may be the parent of a LayoutItem, so that a
# Layout's items only ever nest by translation (see GroupItem). Arbitrary
# parent/child transforms (zoom and rotation inherited about a parent's
# center) would oblige every renderer to compose, invert and decompose
# them, and would conflict with members stacking by their own z. Loosen
# deliberately if a feature needs it, e.g. an annotation pinned to an image.
#
class LayoutItem < CompositionItem

  validates_presence_of :composition
  validate :composition_is_layout
  validate :parent_is_group

  protected

  def parent_is_group
    if parent && !parent.is_a?(LayoutItem::GroupItem)
      errors.add(:parent, 'must be a group')
    end
  end

  def composition_is_layout
    if composition && !composition.is_a?(Layout)
      errors.add(:composition, 'must be a Layout')
    end
  end

end
