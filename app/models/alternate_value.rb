class AlternateValue < ActiveRecord::Base

  include Housekeeping::Users

  belongs_to :language
  belongs_to :alternate_object, polymorphic: true

  validates :language, presence: true, allow_nil: true
  validates_presence_of :type, :value, :alternate_object_attribute 
  validates :alternate_object, presence: true

  before_validation :ensure_object_has_attribute, :ensure_alternate_value_is_not_identical

  def original_value
    (self.alternate_object_attribute && self.alternate_object && self.alternate_object.respond_to?(self.alternate_object_attribute.to_sym) )  ? self.alternate_object.send(self.alternate_object_attribute.to_sym)  : nil
  end

  protected

  def ensure_object_has_attribute
    errors.add(:alternate_object_attribute, 'no attribute (column) with that name') if self.alternate_object && !self.alternate_object.class.column_names.include?(self.alternate_object_attribute.to_s) 
  end 

  def ensure_alternate_value_is_not_identical
    errors.add(:value, 'value is not alternate, is identical to existing value') if self.value == self.original_value 
  end

end
