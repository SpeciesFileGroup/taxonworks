# A controlled vocabulary term is a user defineable attribute, a name and definition is required.
#
# @!attribute type
#   @return [String]
#    The subclass of the CVT.
#
# @!attribute name
#   @return [String]
#     The term name.
#
# @!attribute definition
#   @return [String]
#    The term definition, required.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute uri
#   @return [String]
#    A URI for an external concept that matches this CVT.
#
# @!attribute uri_relation
#   @return [String]
#     A SKOS relationship that defines/describes the relationship between the concept identified by the URI and the concept defined in the definition.
#
class ControlledVocabularyTerm < ApplicationRecord
  # ControlledVocabularyTerms are NOT taggable
  include Housekeeping
  include Shared::AlternateValues
  include Shared::HasPapertrail
  include Shared::IsData
  include SoftValidation

  acts_as_list scope: [:project_id, :type]

  # Class constants
  ALTERNATE_VALUES_FOR = [:name, :definition].freeze

  validates_presence_of :name, :definition, :type
  validates_length_of :definition, minimum: 20

  validates_uniqueness_of :name, scope: [:type, :project_id]
  validates_uniqueness_of :definition, scope: [:project_id]
  validates_uniqueness_of :uri, scope: [:project_id, :uri_relation], allow_blank: true
  validates_presence_of :uri, unless: -> {uri_relation.blank?}, message: 'must be provided if uri_relation is provided'

  validate :uri_relation_is_a_skos_relation, unless: -> {uri_relation.blank?}

  has_many :observation_matrix_row_items, inverse_of: :controlled_vocabulary_term, class_name: 'ObservationMatrixRowItem::Dynamic::Tag', dependent: :destroy
  has_many :observation_matrix_column_items, inverse_of: :controlled_vocabulary_term, class_name: 'ObservationMatrixColumnItem::Dynamic::Tag', dependent: :destroy
  
  has_many :observation_matrices, through: :observation_matrix_row_items



  scope :of_type, -> (type) { where(type: type.to_s.capitalize) } # TODO, capitalize is not the right method for things like `:foo_bar`

  protected

  # @return [Object]
  def uri_relation_is_a_skos_relation
    errors.add(:uri_relation, 'is not a valid uri relation') if !SKOS_RELATIONS.keys.include?(uri_relation)
  end

end

require_dependency 'biocuration_class'
require_dependency 'biological_property'
require_dependency 'keyword'
require_dependency 'predicate'
require_dependency 'topic'
require_dependency 'confidence_level'

