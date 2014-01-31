class Note < ActiveRecord::Base
  include Housekeeping
  # notes are project specific

  belongs_to :note_object, polymorphic: true
  validates :note_object, presence: true
  validates_presence_of :note_object_id
  validates_presence_of :text

  before_validation :not_a_housekeeping_field, :is_valid_attribute
  
  protected
  def not_a_housekeeping_field
    if !(self.note_object_attribute.blank?)
      errors.add(:note_object_attribute, 'can not add a note to this attribute (column)') if
          ::NON_ANNOTATABLE_COLUMNS.include?(self.note_object_attribute.to_sym)
    end
  end

  def is_valid_attribute
    if !(self.note_object_attribute.blank?)
      errors.add(:note_object_attribute, 'not a valid attribute (column)') if
          !(self.note_object.attributes.include?(self.note_object_attribute.to_s))
    end
  end
end
