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
  # ControlledVocabularyTerms are NOT Taggable (with 'Tag')
  include Housekeeping
  include Shared::AlternateValues
  include Shared::HasPapertrail
  include Shared::IsData
  include SoftValidation

  acts_as_list scope: [:project_id, :type]

  ALTERNATE_VALUES_FOR = [:name, :definition].freeze

  validates_presence_of :name, :definition, :type
  validates_length_of :definition, minimum: 20

  validates_uniqueness_of :name, scope: [:type, :project_id]
  validates_uniqueness_of :definition, scope: [:project_id]

  validates_uniqueness_of :uri, scope: [:project_id, :uri_relation], allow_blank: true
  validates_presence_of :uri, unless: -> {uri_relation.blank?}, message: 'must be provided if uri_relation is provided'

  # TODO: DRY with Identifier::Global::Uri
  validate :form_of_uri
  validate :uri_relation_is_a_skos_relation

  has_many :observation_matrix_row_items, as: :observation_object, inverse_of: :observation_object,  class_name: 'ObservationMatrixRowItem::Dynamic::Tag', dependent: :destroy
  has_many :observation_matrix_column_items, inverse_of: :controlled_vocabulary_term, class_name: 'ObservationMatrixColumnItem::Dynamic::Tag', dependent: :destroy

  # TODO: this needs to come through columns rows
  has_many :observation_matrices, through: :observation_matrix_row_items

  scope :of_type, -> (type) { where(type: type.to_s.capitalize) } # TODO, capitalize is not the right method for things like `:foo_bar`

  protected

  def self.clone_from_project(from_id: nil, to_id: nil, klass: nil)
    return false if from_id.blank? or to_id.blank? or klass.blank?

    k = klass.safe_constantize
    k.where(project_id: from_id, type: klass).find_each do |cvt|
      begin
        i = cvt.dup
        i.project_id = to_id
        i.save!
      rescue ActiveRecord::RecordInvalid
      end
    end
    true
  end

  # def form_of_uri
  #   if uri.present?
  #     uris = URI.extract(uri)

  #     if uris.count == 0
  #       errors.add(:uri, 'More than a single URI present')
  #     else
  #       unless (uri.lenght == uris[0].length) && (uris.count == 1)
  #     end
  #   end
  # end

  def form_of_uri
    if uri.present?

      uris = URI.extract(uri)

      if uris.count == 0
        errors.add(:uri, 'URI provided by unparsable.')
      elsif uris.count > 1
        errors.add(:uri, 'More than a single URI present.')
      else
        begin
          u = URI(uri)
          scheme = u.scheme.upcase
          unless URI.scheme_list.keys.include?(scheme)
            errors.add(:uri, "#{scheme} is not in the URI schemes list.")
          end
        rescue
          errors.add(:uri, "Badly formed URI #{uri} detected.")
        end
      end
    end
  end

  # @return [Object]
  def uri_relation_is_a_skos_relation
    if uri.present? && uri_relation.present?
      errors.add(:uri_relation, 'is not a valid uri relation') if !SKOS_RELATIONS.keys.include?(uri_relation)
    end
  end

end

# require_dependency 'biocuration_class'
# require_dependency 'biological_property'
# require_dependency 'keyword'
# require_dependency 'predicate'
# require_dependency 'topic'
# require_dependency 'confidence_level'
