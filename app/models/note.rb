# A note is a text annotation on a data instance (record).
#
# Notes are text only annotations on instances that belong to some project (i.e. models that include Housekeeping::Projects).
# Notes can not be cited.
#
# To annotate global (models that do not include Housekeeping::Projects) instances use a DataAttribute.
#
# @!attribute text
#   @return [String]
#     The content of the note.  Markdown is supported.
#
# @!attribute note_object_type
#   @return [String]
#     The object type being annotated
#
# @!attribute note_object_id
#   @return [String]
#     The object id being annotated
#
# #@!attribute note_object_attribute
#   @return [String]
#     The specific attribute being annotated.
#
# @!attribute project_id
#   @return [Integer]
#
class Note < ApplicationRecord
  # Notes can not be cited!
  include Housekeeping
  include Shared::AttributeAnnotations
  include Shared::Tags
  include Shared::PolymorphicAnnotator
  include Shared::IsData

  polymorphic_annotates(:note_object)
  ignore_whitespace_on(:text)

  # Please DO NOT include the following, they get in the way
  # of the present housekeeping approach. A not null constraint exists
  # to catch these.
  #    validates_associated :note_object
  #    validates_presence_of :note_object_id, :note_object_type
  validates_presence_of :text
  validates_uniqueness_of :text, scope: [:note_object_id, :note_object_type, :project_id]

  def self.annotated_attribute_column
    :note_object_attribute
  end

  def self.annotation_value_column
    :text
  end

  # TODO: make a helper
  # Format a note
  def note_string
    "#{updated_at}: #{updater.name}: #{text}" + (note_object_attribute.blank? ? '' : "[on: #{note_object_attribute}]")
  end

end
