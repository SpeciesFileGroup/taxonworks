# STUB, see https://github.com/SpeciesFileGroup/taxonworks/issues/1783
# See lib/export/dwca/gbif_profiel/core_taxon.rb for early start
# TODO: See collection_object/dwc_extensions for methods that might migrate here, 
module Otu::DwcExtensions

  extend ActiveSupport::Concern

  # DWC_OCCURRENCE_MAP = {
    #dateIdentified: :dwc_date_identified,
    #family: :dwc_family,
    #genus: :dwc_genus,
    #infraspecificEpithet: :dwc_infraspecific_epithet,
    #kingdom: :dwc_kingdom,
    #nomenclaturalCode: :dwc_nomenclatural_code,
    #previousIdentifications: :dwc_previous_identifications,
    #recordedBy: :dwc_recorded_by,
    #recordedByID: :dwc_recorded_by_id,
    #scientificName: :dwc_scientific_name,
    #scientificNameAuthorship: :dwc_taxon_name_authorship,
    #specificEpithet: :dwc_specific_epithet,
    #taxonRank: :dwc_taxon_rank,

    # -- Core taxon? -- 
    # nomenclaturalCode 
    # scientificName
    # taxonmicStatus
    # scientificNameAuthorship
    # scientificNameID
    # taxonRank
    # namePublishedIn
  #}.freeze

  # included do
  # end

  # Deprecated for new approach in CollectionObject, AssertedDistribution, and ultimately here
  # def dwca_core
  #   # Target fields are listed in CoreTaxon, move them here (or maybe shift everything to there ultimately as service objects)
  #   core = Export::Dwca::GbifProfile::CoreTaxon.new
  #   core.nomenclaturalCode        = (taxon_name.rank_class.nomenclatural_code.to_s.upcase)
  #   core.taxonomicStatus          = (taxon_name.unavailable_or_invalid? ? nil : 'accepted')
  #   core.nomenclaturalStatus      = (taxon_name.classification_invalid_or_unavailable? ? nil : 'available') # needs tweaking
  #   core.scientificName           = taxon_name.cached
  #   core.scientificNameAuthorship = taxon_name.cached_author_year
  #   core.scientificNameID         = taxon_name.identifiers.first.identifier
  #   core.taxonRank                = taxon_name.rank
  #   core.namePublishedIn          = taxon_name.source.cached
  #   core
  # end

end
