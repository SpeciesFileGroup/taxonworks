# A LayoutItem places a specific thing in a Layout.
#
# Only a LayoutItem::GroupItem may be the parent of a LayoutItem, so that a
# Layout's items only ever nest by translation (see GroupItem). Arbitrary
# parent/child transforms (zoom and rotation inherited about a parent's
# center) would oblige every renderer to compose, invert and decompose
# them, and would conflict with members stacking by their own z. Loosen
# deliberately if a feature needs it, e.g. an annotation pinned to an image.
#
# What a LayoutItem class may place comes from object concerns it includes
# (e.g. Shared::Render::DepictionItem), several per class. So that they
# combine safely, an object concern:
# * permits its class in a .composition_item_object_permitted? that falls
#   back to super, so a class permits whatever any of its concerns permit
# * guards its validations and callbacks by the object's type
# * prefixes any other methods with its type (e.g. depiction_...), so that
#   no concern overrides another's
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
