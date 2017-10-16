# A note is a text annotation on a data instance (record).
#
# Notes are text only annotations on instances that belong to some project (i.e. models that include Housekeeping::Projects).
#
# To annotate global (models that do not include Housekeeping::Projects) instances use a DataAttribute.
#
# @!attribute text
#   @return [String]
#     The content of the note, in Markdown if you wish.
#
# @!attribute note_object_type
#   @return [String]
#     The object being annotated.
#
# @!attribute note_object_attribute
#   @return [String]
#     The specific attribute being annotated.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class Note < ApplicationRecord
  include Housekeeping
  include Shared::IsData
  include Shared::AttributeAnnotations
  include Shared::Taggable
  include Shared::PolymorphicAnnotator
  polymorphic_annotates(:note_object)
  
  # Please DO NOT include the following, they get in the way
  # of the present housekeeping approach. A not null constraint exists
  # to catch these at present.
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

  def self.find_for_autocomplete(params)
    where('text LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
  end

  # TODO: make a helper
  # Format a note
  def note_string
    "#{updated_at}: #{updater.name}: #{text}" + (note_object_attribute.blank? ? "" : "[on: #{note_object_attribute}]")
  end

end
