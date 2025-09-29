# A lightweight but extensible reference to anatomy. It refers to physical
# objects as instances or concepts (see is_material) The concept is a data node,
# with inference happening if/when linkages to an Ontology exist. I.e. we are
# storing only very light-weight data.
# Use cases:
#     Collector goes to field, takes a punch of a fish fin, and returns it ->
#     AnatomicalPart has_origin FieldOccurrence A wing is dissected from a
#     specimen -> AnatomicalPart has_origin Specimen A feather is removed from a
#     bird, and a punch from the feather -> AnatomicalPart has_origin
#     AnatomicalPart has_origin FieldOccurrence A louse is collected from the
#     Ear of a bat, the louse is collected, the Bat is not - AnatomicalPart
#     (ear) has_origin FieldOCcurrence (bat) -> BiologicalAssociation <-
#     CollectionObject (louse)
#
# @!attribute name
#   @return [String]
#   Name of the anatomical part.
#
# @!attribute uri
#   @return [String]
#   Ontology uri of the anatomical part.
#
# @!attribute uri_label
#   @return [String]
#   Uri label of the uri for the anatomical part.
#
# @!attribute is_material
#   @return [Boolean]
#   Whether or not the anatomical part is based on a physical object - *a* head
#   vs. *some* head.
#
# @!cached
#   @return [String]
#
# @!taxonomic_origin_object_id
#   @return [Integer]
#   Polymorhpic object id of the root of the directed tree this anatomical part
#   belongs to. Provides the relation of this part to taxonomy.
#
# @!taxonomic_origin_object_type
#   @return [String]
#   Polymorphic bject type of the root of the directed tree this anatomical part
#   belongs to. Provides the relation of this part to taxonomy.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class AnatomicalPart < ApplicationRecord
  include Housekeeping
  include Shared::Uri
  include Shared::Citations
  include Shared::Confidences
  include Shared::DataAttributes
  include Shared::Depictions
  include Shared::Conveyances
  include Shared::HasPapertrail
  include Shared::Identifiers
  include Shared::Loanable
  include Shared::BiologicalAssociations
  include Shared::Taxonomy
  include Shared::Notes
  include Shared::Observations
  include Shared::Containable
  include Shared::OriginRelationship
  include Shared::ProtocolRelationships
  include Shared::Tags
  include Shared::IsData
  include SoftValidation
  include Shared::PolymorphicAnnotator
  polymorphic_annotates('taxonomic_origin_object')

  is_origin_for 'AnatomicalPart', 'Extract', 'Sequence', 'Sound'
  originates_from 'Otu', 'Specimen', 'Lot', 'AnatomicalPart', 'FieldOccurrence'

  GRAPH_ENTRY_POINTS = [:origin_relationships]

  attr_accessor :no_cached

  belongs_to :taxonomic_origin_object, polymorphic: true, inverse_of: :anatomical_parts

  after_save :set_cached, unless: -> { self.no_cached }

  validate :name_or_uri_not_both
  validate :taxonomic_origin_object_is_valid_type
  validate :taxonomic_origin_object_relates_to_otu

  private

  def set_cached
    # TODO
    update_column(:cached, name)
  end

  def name_or_uri_not_both
    has_labelled_uri = uri.present? && uri_label.present?
    return if has_labelled_uri && !name.present?
    return if name.present? && !has_labelled_uri

    errors.add(:base, 'Exactly one of 1) name, or 2) uri *and* uri_label, must be present')
  end

  def taxonomic_origin_object_is_valid_type
    return if taxonomic_origin_object.nil?
    valid = ['Otu', 'CollectionObject', 'FieldOccurrence']
    t = taxonomic_origin_object.class.base_class.name
    return if valid.include?(t)

    errors.add(:base, "Class of taxonomic_origin_object must be in [#{valid.join(', ')}], not #{t}")
  end

  def taxonomic_origin_object_relates_to_otu
    return if taxonomic_origin_object.nil?
    t = taxonomic_origin_object.class.base_class.name
    return if t == 'Otu' || taxonomic_origin_object.taxon_determinations.exists?

    errors.add(:base, 'taxonomic_origin_object is required to have a taxon determination')
  end

end
