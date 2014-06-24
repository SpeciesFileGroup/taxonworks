class AlternateValue < ActiveRecord::Base

  include Housekeeping::Users

  belongs_to :language
  belongs_to :alternate_object, polymorphic: true

  validates :language, presence: true, allow_nil: true
  validates_presence_of :type, :value, :alternate_object_attribute 
  validates :alternate_object, presence: true

  before_validation :ensure_object_has_attribute,
                    :ensure_alternate_value_is_not_identical,
                    :validate_alternate_value_type,
                    :not_empty_original_value

  def original_value
    (self.alternate_object_attribute && self.alternate_object && self.alternate_object.respond_to?(
        self.alternate_object_attribute.to_sym) )  ?
        self.alternate_object.send(self.alternate_object_attribute.to_sym)  : nil
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

  protected

  def validate_alternate_value_type
    errors.add(:type, "Is not valid type") if !self.type.nil? and !ALTERNATE_VALUE_CLASS_NAMES.include?(self.type.to_s)
  end


  def ensure_object_has_attribute
    errors.add(:alternate_object_attribute, 'No attribute (column) with that name') if
        self.alternate_object &&
            !self.alternate_object.attributes.include?(self.alternate_object_attribute.to_s)
  end 

  def ensure_alternate_value_is_not_identical
    errors.add(:value, 'Value is not alternate, is identical to existing value') if
        (self.value == self.original_value)
  end

  def not_empty_original_value
    errors.add(:value, 'No alternate value is allowed to empty field') if self.original_value.blank?
  end

end
