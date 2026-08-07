# The identifier that is globally unique.
#
# Curators of a specific project assert one canonical global identifier per type for each object, this
# identifier is identified by having .relation.nil?.  If the curators feel there are multiple global identifiers
# for a given instance they must provide an explicit relationship between the canonical identifier and the
# alternate identifiers.
#
# @!attribute relation
#   @return [String]
#   Defines the relationship between the curator asserted canonical identifier and other identifiers
#   of the same type. Must be provided for every global identifier of the same type beyond the first.
#   Relations are drawn from skos (http://www.w3.org/TR/skos-reference/#mapping)
#
class Identifier::Global < Identifier

  include SoftValidation

  # Only implemented for a couple, but for now DRYer to keep here
  include Shared::DwcOccurrenceHooks

  validates :namespace_id, absence: true
 
  # DEPRECATED: unused in 10 years, benefit seems doubtful.
  validates :relation, inclusion: {in: ::SKOS_RELATIONS.keys}, allow_nil: true

  # Identifier can only be used once, i.e. mapped to a single TW concept
  validates_uniqueness_of :identifier, scope: [:project_id]

  soft_validate(:sv_resolves?, set: :resolved)

  def is_global?
    true
  end

  def dwc_occurrences

    return DwcOccurrence.none unless %w{
     Identifier::Global::Wikidata
     Identifier::Global::Orcid
    }.include?(type)

    # Collectors
    a = DwcOccurrence.joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins('JOIN collecting_events ce on co.collecting_event_id = ce.id')
      .joins("JOIN roles r on r.type = 'Collector' AND r.role_object_type = 'CollectingEvent' AND r.role_object_id = ce.id")
      .joins("JOIN identifiers i on i.identifier_object_id = r.person_id AND i.identifier_object_type = 'Person' AND i.type =  '#{type}' ")
      .where(i: {id:})
      .distinct

    # Determiners
    b = DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins("JOIN taxon_determinations td on co.id = td.taxon_determination_object_id AND td.taxon_determination_object_type = 'CollectionObject'")
      .joins("JOIN roles r on r.type = 'Determiner' AND r.role_object_type = 'TaxonDetermination' AND r.role_object_id = td.id")
      .joins("JOIN identifiers i on i.identifier_object_id = r.person_id AND i.identifier_object_type = 'Person' AND i.type = '#{type}'")
      .where(r: {id:})
      .distinct

    ::Queries.union(::DwcOccurrence, [a,b])
  end

  protected

  def build_cached
    identifier
  end

  # TODO: add a resolution method so that this works on theings like wikidata Q numbers
  def sv_resolves?
    responded = identifier.present? && (Utilities::Net.resolves?(identifier) rescue false)
    soft_validations.add(:identifier, "Identifier '#{identifier}' does not resolve.") unless responded
    responded
  end

end
