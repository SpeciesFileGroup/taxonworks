# A Tag links a ControlledVocabularyTerm::Keyword to a Data object.
#
# @!attribute keyword_id
#   @return [Integer]
#      the keyword used in this tag
#
# @!attribute tag_object_id
#   @return [Integer]
#      Rails polymorphic, id of the object being tagged
#
# @!attribute tag_object_type
#   @return [String]
#      Rails polymorphic, type of the object being tagged
#
# @!attribute tag_object_attribute
#   @return [String]
#      the specific attribute being referenced with the tag (not required)
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute position
#   @return [Integer]
#     a user definable sort code on the tags on an object, handled by acts_as_list
#
class Tag < ApplicationRecord
  
  # Tags can not be cited.
  include Housekeeping
  include Shared::IsData
  include Shared::AttributeAnnotations

  include Shared::MatrixHooks::Dynamic # Must preceed Tag::MatrixHooks
  include Tag::MatrixHooks # Must come after Shared::MatrixHooks::Dynamic 


  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:tag_object)
  acts_as_list scope: [:tag_object_id, :tag_object_type, :keyword_id, :project_id]

  belongs_to :keyword, inverse_of: :tags, validate: true
  belongs_to :controlled_vocabulary_term, foreign_key: :keyword_id, inverse_of: :tags # Not all tagged subclasses are Keyword based, use this object for display.

  validates :keyword, presence: true
  validate :keyword_is_allowed_on_object
  validate :object_can_be_tagged_with_keyword

  validates_uniqueness_of :keyword_id, scope: [:tag_object_id, :tag_object_type]

  accepts_nested_attributes_for :keyword, reject_if: :reject_keyword # , allow_destroy: true

  def self.tag_objects(objects, keyword_id = nil)
    return nil if keyword_id.nil? or objects.empty?
    objects.each do |o|
      o.tags << Tag.new(keyword_id: keyword_id)
    end
  end

  def self.exists?(global_id, keyword_id, project_id)
    o = GlobalID::Locator.locate(global_id)
    return false unless o
    Tag.where(project_id: project_id, tag_object: o, keyword_id: keyword_id).first
  end

  # The column name containing the attribute name being annotated
  def self.annotated_attribute_column
    :tag_object_attribute
  end

  def self.batch_create(keyword_id: nil, object_type: nil, user_id: nil, project_id: nil, object_ids: [])
    begin
      Tag.transaction do 
        object_ids.each do |id|
          Tag.find_or_create_by(keyword_id: keyword_id, tag_object_type: object_type, tag_object_id: id)
        end
      end
    rescue ActiveRecord::RecordInvalid
      return false 
    end
  end

  protected

  def keyword_is_allowed_on_object
    return true if keyword.nil? || tag_object.nil? || !keyword.respond_to?(:can_tag)
    if !keyword.can_tag.include?(tag_object.class.name)
      errors.add(:keyword, "this keyword class (#{tag_object.class}) can not be attached to a #{tag_object_type}")
    end
  end

  def object_can_be_tagged_with_keyword
    return true if keyword.nil? || tag_object.nil? || !tag_object.respond_to?(:taggable_with)
    if !tag_object.taggable_with.include?(keyword.class.name)
      errors.add(:tag_object, "this tag_object_type (#{tag_object.class}) can not be tagged with this keyword class (#{keyword.class})")
    end
  end

  def reject_keyword(attributed)
    attributed['name'].blank? || attributed['definition'].blank?
  end

  def self.tag_objects(objects, keyword_id = nil)
    return nil if keyword_id.nil? or !objects.any?
    raise 'cross project tagging of objects detected' if objects.first.project_id != Keyword.find(keyword_id).project_id
    objects.each do |o|
      o.tags << Tag.new(keyword_id: keyword_id)
    end
  end

  # @return [Boolean]
  #   destroy all tags with the keyword_id provided, true if success, false if failure
  def self.batch_remove(keyword_id, klass = nil)
    return false if keyword_id.blank?
    if klass.blank?
      return true if Tag.where(keyword_id: keyword_id).destroy_all
    else
      return true if Tag.where(keyword_id: keyword_id, tag_object_type: klass).destroy_all
    end
    false
  end

  def keyword_is_allowed_on_object
    return true if keyword.nil? || tag_object.nil? || !keyword.respond_to?(:can_tag)
    if !keyword.can_tag.include?(tag_object.class.name)
      errors.add(:keyword, "this keyword class (#{tag_object.class}) can not be attached to a #{tag_object_type}")
    end
  end

  def object_can_be_tagged_with_keyword
    return true if keyword.nil? || tag_object.nil? || !tag_object.respond_to?(:taggable_with)
    if !tag_object.taggable_with.include?(keyword.class.name)
      errors.add(:tag_object, "this tag_object_type (#{tag_object.class}) can not be tagged with this keyword class (#{keyword.class})")
    end
  end

  def reject_keyword(attributed)
    attributed['name'].blank? || attributed['definition'].blank?
  end

end
