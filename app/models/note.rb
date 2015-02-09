# A note is a text annotation on a data instance (record).
# 
# Notes are text only notes on instances that belong to some project (e.g. models that include Shared::IsData).
# For global instances use DataAttribute
#
# Notes may include any text excluding pipes ('|'). Pipes are a reserved object separator for output
#
class Note < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 
  include Shared::Annotates

  belongs_to :note_object, polymorphic: true
  
  before_validation :not_a_housekeeping_field, :is_valid_attribute, :no_pipes

  # Please DO NOT include the following, they get in the way
  # of the present housekeeping approach. A not null constraint exists
  # to catch these at present. 
  #    validates_associated :note_object
  #    validates_presence_of :note_object_id, :note_object_type
  
  validates_presence_of :text

  # Format a note
  def note_string
    "#{updated_at}: #{updater.name}: #{text}" + (note_object_attribute.blank? ? "" : "[on: #{note_object_attribute}]")
  end

  # @return [NoteObject]
  #   alias to simplify reference across classes 
  def annotated_object
    note_object 
  end

  def self.find_for_autocomplete(params)
    where('text LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
  end

  protected

  def no_pipes
    if !self.text.blank?
      errors.add(:text, 'TW notes may not contain a pipe (|)') if self.text.include?('|')
    end
  end

  def not_a_housekeeping_field
    if !(self.note_object_attribute.blank?)
      errors.add(:note_object_attribute, 'can not add a note to this attribute (column)') if
          ::NON_ANNOTATABLE_COLUMNS.include?(self.note_object_attribute.to_sym)
    end
  end

  def is_valid_attribute
    if !(self.note_object_attribute.blank?)
      attr = self.note_object_attribute.to_s
      errors.add(:note_object_attribute, "#{attr} is not an attribute (column) of #{self.note_object.class}") if
          !(self.note_object.attributes.include?(attr))
    end
  end
end
