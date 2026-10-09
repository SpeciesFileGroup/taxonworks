# A Composition is the arrangement of things for rendering, for example a
# layout of labels on a page. Compositions are Render, not Data.
#
# Composition is not instantiated directly, see Layout and Template.
#
# @!attribute type
#   @return [String]
#     the subclass, e.g. Layout or Template
#
# @!attribute name
#   @return [String]
#     the name of the Composition, unique within type and version
#
# @!attribute description
#   @return [String, nil]
#     a free text description
#
# @!attribute version
#   @return [String, nil]
#     <major>.<minor>.<patch>, see Utilities::SemanticVersion
#
# @!attribute is_community
#   @return [true, nil]
#     true when the Composition is shared across all projects, in which case
#     project_id is nil. Only permitted for some subclasses, see
#     .community_permitted?. Never false, false is stored as nil.
#
# @!attribute project_id
#   @return [Integer, nil]
#     the project ID, nil when is_community
#
class Composition < ApplicationRecord
  include Housekeeping
  include Shared::IsRender

  normalizes :version, with: -> (v) { v.strip.presence }

  # Only true or nil
  normalizes :is_community, with: -> (v) { v.presence }

  before_validation :set_community_project_id

  after_save :set_composition_items_project_id, if: :saved_change_to_project_id?

  has_many :composition_items, inverse_of: :composition, dependent: :destroy

  scope :visible_to_project, -> (project_id) {
    where(project_id:).or(where(is_community: true))
  }

  validates_presence_of :type, :name
  validates :name, uniqueness: { scope: [:project_id, :type, :version] }
  validate :version_is_semantic
  validate :is_community_is_permitted
  validate :community_has_no_item_objects

  # @return [Boolean]
  #   true if *some* instances may be shared across projects (compare
  #   IsData's class-level .is_community?, which means *all* instances are).
  #   Subclasses that reference only model attributes and attribute
  #   modifiers, never instance data, may override this.
  def self.community_permitted?
    false
  end

  # @return [Boolean]
  #   overrides Housekeeping::Projects, which checks the class. Per record,
  #   unlike Data where community is a property of the class. There is no
  #   class-level .is_community? here, nothing asks it of Composition.
  def is_community?
    is_community == true
  end

  # @return [Boolean]
  #   overrides Housekeeping::Projects so that community records are not
  #   required to have a project
  def annotates_community_object?
    is_community?
  end

  protected

  def version_is_semantic
    if version.present? && !Utilities::SemanticVersion.valid?(version)
      errors.add(:version, 'must be <major>.<minor>.<patch>, e.g. 1.0.0')
    end
  end

  def is_community_is_permitted
    if is_community? && !self.class.community_permitted?
      errors.add(:is_community, "is not permitted for #{type}")
    end
  end

  # Community Compositions reference model attributes, not instance data.
  def community_has_no_item_objects
    if is_community? && persisted? &&
        composition_items.where.not(composition_item_object_id: nil).exists?
      errors.add(:is_community, 'is not permitted when items reference objects')
    end
  end

  def set_composition_items_project_id
    composition_items.update_all(project_id:)
  end

  def set_community_project_id
    if is_community?
      self.project_id = nil
    else
      self.project_id ||= Current.project_id
    end
  end

end
