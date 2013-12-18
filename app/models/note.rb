class Note < ActiveRecord::Base
  include Housekeeping

  belongs_to :note_object, polymorphic: true
  validates_presence_of :note_object, :text

  before_validation :not_a_housekeeping_field

  protected
  def not_a_housekeeping_field
    if !(self.note_object_attribute.blank?)
      errors.add(:note_object_attribute, 'can not add a note to a housekeeping field') if
          ::HOUSEKEEPING_COLUMN_NAMES.include?(self.note_object_attribute.to_sym)
      errors.add(:note_object_attribute, 'can not add a note to id field') if
          (self.note_object_attribute.to_s == 'id')
    end
  end
end
