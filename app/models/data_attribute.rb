# A data attribute is used to attach an arbitrary predicate/literal pair to a data instance, essentially creating a user-defined triple. It is the primary mechanism of extending data-models in TaxonWorks.
#
# A DataAttribute is only instantiated through its subclasses ImportAttribute or InternalAttribute
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
#   The class of the subject (Rails polymorphic relationship).
#
# @!attribute controlled_vocabulary_term_id
#   @return [Integer]
#     Id of the Predicate for InternalAttributes
#
# @!attribute value
#   @return [String]
#   The user provided data, e.g., RFD literal or object, i.e. RDF literal, i.e. data in a cell of a spreadsheet.  Always required.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class DataAttribute < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::DualAnnotator
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates('attribute_subject')

  belongs_to :predicate, foreign_key: 'controlled_vocabulary_term_id', inverse_of: :internal_attributes, class_name: 'Predicate'

  # Please DO NOT include the following:  (follows Identifier approach)
  #   validates_presence_of :attribute_subject_type, :attribute_subject_id
  #   validates :attribute_subject, presence: true
  validates_presence_of :type, :value

  # Needs to extend to predicate/value searches
  def self.find_for_autocomplete(params)
    where('value LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
  end

  # @return [Boolean]
  #   true if value can be edited, i.e. an InternalAttribute
  def editable?
    self.type == 'InternalAttribute'
  end

  # @return [String]
  #   the predicate name
  def predicate_name
    # type == 'InternalAttribute' ? predicate.name : import_predicate
    type.start_with?('Im') ? import_predicate : predicate.name
  end

end
