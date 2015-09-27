# A note is a text annotation on a data instance (record).
# 
# Notes are text only notes on instances that belong to some project (e.g. models that include Shared::IsData).
# For global instances use DataAttribute.
#
# Notes may include any text excluding pipes ('|'). Pipes are a reserved object separator for output.
#
# @!attribute text
#   @return [String]
#   @todo
#
# @!attribute note_object_type
#   @return [String]
#   @todo
#
# @!attribute note_object_attribute
#   @return [String]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class Note < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 
  include Shared::AttributeAnnotations
  include Shared::Taggable

  belongs_to :note_object, polymorphic: true
  before_validation :no_pipes

  # Please DO NOT include the following, they get in the way
  # of the present housekeeping approach. A not null constraint exists
  # to catch these at present. 
  #    validates_associated :note_object
  #    validates_presence_of :note_object_id, :note_object_type
  validates_presence_of :text
  validates_uniqueness_of :text, scope: [:note_object_id, :note_object_type, :project_id]

  # Format a note
  def note_string
    "#{updated_at}: #{updater.name}: #{text}" + (note_object_attribute.blank? ? "" : "[on: #{note_object_attribute}]")
  end

  # @return [NoteObject]
  #   alias to simplify reference across classes 
  def annotated_object
    note_object 
  end

  def self.annotated_attribute_column
    :note_object_attribute
  end

  def self.annotation_value_column
    :text
  end

  def self.find_for_autocomplete(params)
    where('text LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  protected

  def no_pipes
    if !self.text.blank?
      errors.add(:text, 'TW notes may not contain a pipe (||)') if self.text.include?('||')
    end
  end
end
