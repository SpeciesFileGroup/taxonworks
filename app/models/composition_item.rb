# A CompositionItem is one thing placed in a Composition, for example a
# block of text in a Template, or a label positioned on a page in a Layout.
# CompositionItems are Render, not Data.
#
# CompositionItem is not instantiated directly. Subclasses define the units
# and meaning of the attributes, and their own uniqueness/constraints.
# Subclasses that use composition_id are named <Composition subclass>Item,
# e.g. LayoutItem, TemplateItem.
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
#
# @!attribute y
#   @return [Float, nil]
#
# @!attribute z
#   @return [Float, nil]
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
# @!attribute rotation_x
#   @return [Float, nil]
#
# @!attribute rotation_y
#   @return [Float, nil]
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
#     the project ID, always that of the Composition when present, nil when
#     the Composition is community
#
class CompositionItem < ApplicationRecord
  include Housekeeping
  include Shared::IsRender

  acts_as_list scope: [:project_id, :composition_id, :parent_id]

  before_validation :set_composition_project_id

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

  # @return [Boolean]
  #   overrides Housekeeping::Projects, which checks the class
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

  def set_composition_project_id
    if composition
      self.project_id = composition.project_id
    else
      self.project_id ||= Current.project_id
    end
  end

  def parent_is_in_composition
    if parent && parent.composition_id != composition_id
      errors.add(:parent, 'must be in the same composition')
    end
  end

  def parent_is_not_self_or_descendant
    p = parent
    while p
      if p == self
        errors.add(:parent, 'may not be self or a descendant')
        break
      end
      p = p.parent
    end
  end

  # Community Compositions reference model attributes, not instance data.
  def community_composition_has_no_object
    if is_community? && composition_item_object_id.present?
      errors.add(:composition_item_object, 'is not permitted in a community composition')
    end
  end

end
