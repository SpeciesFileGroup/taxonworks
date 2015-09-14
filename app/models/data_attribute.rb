# A data attribute is used to attach an arbitrary predicate/literal pair to a data instance, essentially creating a user-defined triple.
#
# DataAttribute is only instantiated through its subclasses ImportAttribute or InternalAttribute
#
# @!attribute type
#   @return [String]
#   The type of DataAttribute (Rails STI).
#
# @!attribute attribute_subject_id
#   @return [Integer]
#   The id of the subject (Rails polymorphic relationship).
#
# @!attribute attribute_subject_type
#   @return [String]
#   THe class of the subject (Rails polymorphic relationship).
#
# @!attribute controlled_vocabulary_term_id
#   @return [Integer]
#   @todo
#
# @!attribute value
#   @return [String]
#   The user provided data, e.g., RFD literal or object, i.e. RDF literal, i.e. data in a cell of a spreadsheet.  Always required.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class DataAttribute < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 
  include Shared::DualAnnotator

#   include Shared::Annotates

  belongs_to :attribute_subject, polymorphic: true

  # Please DO NOT include the following:  (follows Identifier approach)
  #   validates_presence_of :attribute_subject_type, :attribute_subject_id
  #   validates :attribute_subject, presence: true
  validates_presence_of :type, :value
  validates_uniqueness_of :value, scope: [:attribute_subject_id, :attribute_subject_type, :type, :controlled_vocabulary_term_id]

  def self.find_for_autocomplete(params)
    where('value LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
  end

  # @return [NoteObject]
  #   alias to simplify reference across classes 
  def annotated_object
    attribute_subject
  end

  def editable?
    self.type == 'InternalAttribute'
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

end
