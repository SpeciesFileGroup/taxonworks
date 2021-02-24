# A PinboardItem is an object on a user's pinboard.
#
# @!attribute pinned_object_id
#   @return [Integer]
#      the id of the object being pinned
#
# @!attribute pinned_object_type
#   @return [String]
#     the type of the object being pinned
#
# @!attribute user_id
#   @return [Integer]
#      this identifies the pinboard
#
# @!attribute project_id
#   @return [Integer]
#   the project ID for which the object is pinned
#
# @!attribute position
#   @return [Integer]
#     the relative position of this object, nests within object type
#
# @!attribute is_inserted
#   @return [Boolean]
#     when true this pinboard item is automatically inserted into accepting form fields
#
# @!attribute is_cross_project
#   @return [Boolean]
#     pinboard item will show up regardless of which project is selected
#
# @!attribute inserted_count
#   @return [Integer]
#     (not implemented) - the number of times this item has been inserted
#
class PinboardItem < ApplicationRecord
  include Housekeeping

  acts_as_list scope: [:project_id, :pinned_object_type, :user_id]

  belongs_to :user
  belongs_to :pinned_object, polymorphic: true, validate: true

  before_validation  :validate_is_cross_project
  validates_presence_of :user_id, :pinned_object_id, :pinned_object_type
  validates_uniqueness_of :user_id, scope: [ :pinned_object_id, :pinned_object_type, :project_id ]

  after_save :update_insertable

  scope :for_object, -> (object) { where(pinned_object_id: object.id, pinned_object_type: object.class.to_s) }

  def self.reorder_by(pinboard_item_ids)
    pinboard_item_ids.each_with_index do |id, i|
      PinboardItem.find(id).update_attribute(:position, i)
    end
  end

  def is_inserted?
    !is_inserted.blank?
  end

  def is_cross_project?
    !is_cross_project.blank?
  end

  protected

  def update_insertable
    if is_inserted?
      r = PinboardItem.where(project_id: project_id, pinned_object_type: pinned_object_type, user_id: user_id).where.not(id: id)
      if pinned_object_type == 'ControlledVocabularyTerm'
        n = pinned_object.class.name
        r.each do |i|
          i.update_column(:is_inserted, false) if i.pinned_object.type == n
        end 
      else
        r.update_all(is_inserted: false)
      end
    end
  end

  def validate_is_cross_project
    errors.add(:is_cross_project, 'model is not a cross project model') if is_cross_project? && !pinned_object.class.ancestors.map(&:name).include?('Shared::SharedAcrossProjects')
  end

end
