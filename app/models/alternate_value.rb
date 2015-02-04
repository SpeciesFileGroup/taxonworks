# AlternateValue(s) are annotations on an object or object attribute. Use only when the annotations are related
#   to the same thing. (e.g. Hernán vs. Hernan, NOT Bean Books (publisher1) vs. Dell Books(publisher2))
#
# @!attribute attribute_subject_id
#   the ID of the thing being annotated
#
# @!attribute attribute_subject_type
#   the kind of thing being annotated
#
# @!attribute value
#   the annotated value
#
# @!attribute controlled_vocabulary_term_id
#   the ID of the controlled vocabulary term - used only for InternalAttribute
#   Use InternalAttributes when you can precisely define what the alternate value is (e.g. note, MX_ID)
#
# @!attribute import_predicate
#   a string describing the data that has been imported from elsewhere that TW does not have a precise definition for.
#   Used only with ImportAttribute - use when importing outside data and you don't have a definition of the field.
#   (e.g. verbatim_notebook_field_6)
#
class AlternateValue < ActiveRecord::Base

  include Housekeeping
  include Shared::IsData

  belongs_to :language
  belongs_to :alternate_value_object, polymorphic: true

  validates :language, presence: true, allow_nil: true
  validates_presence_of :type, :value, :alternate_value_object_attribute
  validates :alternate_value_object, presence: true

  before_validation :ensure_object_has_attribute,
                    :ensure_alternate_value_is_not_identical,
                    :validate_alternate_value_type,
                    :not_empty_original_value

  def original_value
    (self.alternate_value_object_attribute && self.alternate_value_object && self.alternate_value_object.respond_to?(
        self.alternate_value_object_attribute.to_sym)) ?
        self.alternate_value_object.send(self.alternate_value_object_attribute.to_sym) : nil
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
    r
  end

  def self.class_name
    self.name.demodulize.underscore.humanize.downcase
  end

  def self.find_for_autocomplete(params)
    where('value LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
  end

  def klass_name
    self.class.class_name
  end

  protected

  def validate_alternate_value_type
    errors.add(:type, 'Is not valid type') if !self.type.nil? and !ALTERNATE_VALUE_CLASS_NAMES.include?(self.type.to_s)
  end

  def ensure_object_has_attribute
    # object must not only have this attribute, it must also be explicitly listed in ALTERNATE_VALUE_FOR

    if self.alternate_value_object &&
        !self.alternate_value_object.attributes.include?(self.alternate_value_object_attribute.to_s)
      errors.add(:alternate_value_object_attribute, 'No attribute (column) with that name')
    else
      if self.alternate_value_object &&
          !self.alternate_value_object.class::ALTERNATE_VALUES_FOR.include?(self.alternate_value_object_attribute.to_sym)
        errors.add(:alternate_value_object_attribute, 'Attribute (column) does not allow alternate values.')
      end
    end
  end

  def ensure_alternate_value_is_not_identical
    errors.add(:value, 'Value is not alternate, is identical to existing value') if (self.value == self.original_value)
  end

  def not_empty_original_value
    errors.add(:value, 'An alternate value cannot be assigned to an empty field') if self.original_value.blank?
  end

end
