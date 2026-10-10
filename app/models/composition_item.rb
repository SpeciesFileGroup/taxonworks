# A CompositionItem is one thing placed in a Composition, for example a
# block of text in a Template, or a label positioned on a page in a Layout.
# CompositionItems are Render, not Data.
#
# CompositionItem is not instantiated directly. Subclasses define the units
# and meaning of the attributes, and their own uniqueness/constraints.
# Subclasses that use composition_id are named <Composition subclass>Item,
# e.g. LayoutItem, TemplateItem.
#
# Coordinate system (units are defined by subclasses):
# * Left-handed, as CSS: x increases right, y increases down, z increases
#   toward the viewer (higher z is in front, as CSS z-index). Renderers
#   using a right-handed system (e.g. WebGL/three.js) negate y at their
#   boundary.
# * The origin is the top-left of the Composition, or of the parent item
#   when parent_id is set: child coordinates are relative to the parent,
#   and the parent's rotation and zoom apply to its children (as nested
#   SVG <g> transforms), so moving a parent moves its children.
# * x, y locate the item's top-left corner; width and height extend right
#   and down from there.
# * Rotations pivot on the item's center (as the CSS transform-origin
#   default). A positive rotation_z is clockwise as seen by the viewer.
# * Stacking: higher z is in front. A nil z is 0. Equal z is broken by id,
#   lower (older) behind, so every renderer paints identically.
# * In a Layout only a LayoutItem::GroupItem may be a parent, and groups are
#   translation only, see there.
#
# @!attribute type
#   @return [String]
#     the subclass
#
# @!attribute composition_id
#   @return [Integer, nil]
#     the Composition, not required (e.g. Label)
#
# @!attribute composition_item_object_id
#   @return [Integer, nil]
#     polymorphic id of the thing composed
#
# @!attribute composition_item_object_type
#   @return [String, nil]
#     polymorphic type of the thing composed
#
# @!attribute parent_id
#   @return [Integer, nil]
#     the parent CompositionItem, in the same Composition
#
# @!attribute text
#   @return [String, nil]
#
# @!attribute x
#   @return [Float, nil]
#     left edge, increases right, see Coordinate system
#
# @!attribute y
#   @return [Float, nil]
#     top edge, increases down, see Coordinate system
#
# @!attribute z
#   @return [Float, nil]
#     increases toward the viewer, see Coordinate system
#
# @!attribute position
#   @return [Integer]
#     order among siblings (same composition and parent), see acts_as_list
#
# @!attribute svg_view_box
#   @return [String, nil]
#     sensu Depiction
#
# @!attribute svg_clip
#   @return [String, nil]
#     xml, sensu Depiction
#
# @!attribute width
#   @return [Integer, nil]
#
# @!attribute height
#   @return [Integer, nil]
#
# @!attribute zoom
#   @return [Float, nil]
#
# @!attribute rotation_z
#   @return [Float, nil]
#     rotation about the z axis (out of the page), i.e. flat, in-plane
#     rotation, see Coordinate system and e.g. CSS rotateZ()
#
# @!attribute opacity
#   @return [Float, nil]
#     0..100
#
# @!attribute is_visible
#   @return [Boolean, nil]
#
# @!attribute total
#   @return [Integer, nil]
#
# @!attribute css_style
#   @return [String, nil]
#
# @!attribute project_id
#   @return [Integer, nil]
#     the project ID, nil when the Composition is community. Otherwise set
#     as for any project data (Housekeeping), so a Composition in another
#     project fails Housekeeping's same-project check
#
class CompositionItem < ApplicationRecord
  include Housekeeping
  include Shared::IsRender

  acts_as_list scope: [:project_id, :composition_id, :parent_id]

  before_validation :set_community_project_id

  belongs_to :composition, inverse_of: :composition_items
  belongs_to :composition_item_object, polymorphic: true
  belongs_to :parent, class_name: 'CompositionItem', inverse_of: :children

  has_many :children, class_name: 'CompositionItem', foreign_key: :parent_id,
    inverse_of: :parent, dependent: :destroy

  validates_presence_of :type
  validates :opacity, numericality: { in: 0..100 }, allow_nil: true
  validate :parent_is_in_composition
  validate :parent_is_not_self_or_descendant
  validate :community_composition_has_no_object
  validate :composition_item_object_is_permitted

  # @return [Boolean]
  #   Unify (ApplicationEnumeration.relation_targets_community?) asks this
  #   of classes that Data has_many of. Items that reference objects are
  #   never community, see #community_composition_has_no_object.
  def self.is_community?
    false
  end

  # @return [Boolean]
  #   true if instances of klass may be the composition_item_object.
  #   Abstract: no objects are permitted unless a subclass says so.
  def self.composition_item_object_permitted?(klass)
    false
  end

  # @return [Boolean]
  #   overrides Housekeeping::Projects, which checks the class. Per record,
  #   follows the Composition, see Composition#is_community?
  def is_community?
    composition&.is_community? ? true : false
  end

  # @return [Boolean]
  #   overrides Housekeeping::Projects so that items of community
  #   Compositions are not required to have a project
  def annotates_community_object?
    is_community?
  end

  protected

  # Items of a community Composition have no project. Other items are left
  # to Housekeeping, as for any project data.
  def set_community_project_id
    self.project_id = nil if is_community?
  end

  def parent_is_in_composition
    if parent && parent.composition_id != composition_id
      errors.add(:parent, 'must be in the same composition')
    end
  end

  def parent_is_not_self_or_descendant
    seen = []
    p = parent
    # seen guards against a cycle already in the data that excludes self
    while p && !seen.include?(p)
      if p == self
        errors.add(:parent, 'may not be self or a descendant')
        break
      end
      seen.push(p)
      p = p.parent
    end
  end

  def composition_item_object_is_permitted
    if composition_item_object &&
        !self.class.composition_item_object_permitted?(
          composition_item_object.class
        )
      errors.add(:composition_item_object_type, 'is not permitted')
    end
  end

  # Community Compositions reference model attributes, not instance data.
  def community_composition_has_no_object
    if is_community? && composition_item_object_id.present?
      errors.add(:composition_item_object, 'is not permitted in a community composition')
    end
  end

end
