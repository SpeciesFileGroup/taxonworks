# AlternateValue(s) are annotations on an object or object attribute. Use only when the annotations are related
# to the same thing. (e.g. Hernán vs. Hernan, NOT Bean Books (publisher1) vs. Dell Books (publisher2))
#
# If you want the annotation to be community wide and it's a valid target use `is_community_annotation: true`.
#
# @!attribute value
#   @return [String]
#   the annotated value
#
# @!attribute type
#   @return [String]
#   the annotated type
#
# @!attribute alternate_value_object_attribute
#   @return [String]
#    the attribute (column) that this is an alternate value for
#
# @!attribute attribute_value_object_id
#   @return [Integer]
#   the ID of the thing being annotated
#
# @!attribute alternate_value_object_type
#   @return [String]
#   the kind of thing being annotated
#
# @!attribute language_id
#   @return [Integer]
#   the ID of the language used for translation
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class AlternateValue < ApplicationRecord
  include Housekeeping
  include Shared::DualAnnotator
  include Shared::AttributeAnnotations
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:alternate_value_object)

  belongs_to :language

  # Please DO NOT include the following:
  # validates :alternate_value_object, presence: true

  validates :language, presence: true, allow_blank: true
  validates_presence_of :type, :value, :alternate_value_object_attribute
  validates_uniqueness_of :value, scope: [:alternate_value_object, :type, :alternate_value_object_attribute, :project_id] # !! think about project/community on same object

  def self.class_name
    self.name.demodulize.underscore.humanize.downcase
  end

  def klass_name
    self.class.class_name
  end

  def self.find_for_autocomplete(params)
    where('value ILIKE ? AND ((project_id IS NULL) OR (project_id = ?))',
          "%#{params[:term]}%", params[:project_id])
  end

  # @return [Symbol]
  #   the column name containing the attribute name being annotated
  def self.annotated_attribute_column
    :alternate_value_object_attribute
  end

  def self.annotation_value_column
    :value
  end

  def type_name
    r = self.type.to_s
    ALTERNATE_VALUE_CLASS_NAMES.include?(r) ? r : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type).to_s
    r = ALTERNATE_VALUE_CLASS_NAMES.include?(r) ? r.safe_constantize : nil
  end

end

require_dependency 'alternate_value/misspelling'
require_dependency 'alternate_value/translation'
require_dependency 'alternate_value/abbreviation'
require_dependency 'alternate_value/alternate_spelling'
