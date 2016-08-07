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
#     acts_as_list sort, scope is tagged object
#
class Tag < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData
  include Shared::AttributeAnnotations
  include Shared::MatrixHooks

  acts_as_list scope: [:keyword_id]

  belongs_to :keyword
  belongs_to :tag_object, polymorphic: true

  # Not all tagged subclasses are keyword based, use this object for display
  belongs_to :controlled_vocabulary_term, foreign_key: :keyword_id 

  validates :keyword, presence: true
  validate :keyword_is_allowed_on_object, :object_can_be_tagged_with_keyword

  validates_uniqueness_of :keyword_id, scope: [:tag_object_id, :tag_object_type]

  accepts_nested_attributes_for :keyword, reject_if: :reject_keyword, allow_destroy: true

  def tag_object_class
    tag_object.class
  end

  def tag_object_global_entity
    self.tag_object.to_global_id if self.tag_object.present?
  end

  def tag_object_global_entity=(entity)
    self.tag_object = GlobalID::Locator.locate entity
  end

  def self.find_for_autocomplete(params)
    # where('name LIKE ?', "#{params[:term]}%")
    # todo: @mjy below code is running but not giving results we want
    terms = params[:term].split.collect { |t| "'#{t}%'" }.join(' or ')
    joins(:keyword).where('controlled_vocabulary_terms.name like ?', terms).with_project_id(params[:project_id]) # "#{params[:term]}%" )
  end

  # @return [TagObject]
  #   alias to simplify reference across classes 
  def annotated_object
    tag_object
  end

  # the column name containing the attribute name being annotated
  def self.annotated_attribute_column
    :tag_object_attribute
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).find_each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  # @return [MatrixColumnItem instance, false]
  #   the object corresponding to the keyword used in this tag if it exists
  def matrix_column_item
    i = MatrixColumnItem::TaggedDescriptor.where(controlled_vocabulary_term_id: keyword_id).limit(1)
    i.first if i.any?
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

end
