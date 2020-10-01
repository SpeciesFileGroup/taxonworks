# STUB, see https://github.com/SpeciesFileGroup/taxonworks/issues/1783

module Otu::DwcExtensions

  extend ActiveSupport::Concern

  # A current list of mappable values
  DWC_OCCURRENCE_MAP = {
   #catalogNumber: :dwc_catalog_number,
   #country: :dwc_country,
   #county: :dwc_county,
   #dateIdentified: :dwc_date_identified,
   #eventDate: :dwc_event_date,
   #eventTime: :dwc_event_time,
   #family: :dwc_family,
   #fieldNumber: :dwc_field_number,
   #genus: :dwc_genus,
   #habitat: :dwc_verbatim_habitat,
   #identifiedBy: :dwc_identified_by,
   #identifiedByID: :dwc_identified_by_id,
   #individualCount: :dwc_individual_count,
   #infraspecificEpithet: :dwc_infraspecific_epithet,
   #institutionCode: :dwc_institution_code,
   #institutionID: :dwc_institution_id,
   #kingdom: :dwc_kingdom,
   #lifeStage: :dwc_life_stage,
   #maximumElevationInMeters: :dwc_maximum_elevation_in_meters,
   #minimumElevationInMeters: :dwc_minimum_elevation_in_meters,
   #nomenclaturalCode: :dwc_nomenclatural_code,
   #otherCatalogNumbers: :dwc_other_catalog_numbers,
   #preparations: :dwc_preparations,
   #previousIdentifications: :dwc_previous_identifications,
   #recordedBy: :dwc_recorded_by,
   #recordedByID: :dwc_recorded_by_id,
   #samplingProtocol: :dwc_sampling_protocol,
   #scientificName: :dwc_scientific_name,
   #scientificNameAuthorship: :dwc_taxon_name_authorship,
   #sex: :dwc_sex,
   #specificEpithet: :dwc_specific_epithet,
   #stateProvince: :dwc_state_province,
   #taxonRank: :dwc_taxon_rank,
   #typeStatus: :dwc_type_status,
   #verbatimElevation: :dwc_verbatim_elevation,
   #verbatimEventDate: :dwc_verbatim_event_date,
   #verbatimLocality: :dwc_verbatim_locality,
   #waterBody: :dwc_water_body,
   #
   ## Georeference "Interface'
   #verbatimCoordinates: :dwc_verbatim_coordinates,
   #verbatimLatitude: :dwc_verbatim_latitude,
   #verbatimLongitude: :dwc_verbatim_longitude,
   #decimalLatitude: :dwc_latitude,
   #decimalLongitude: :dwc_longitude,

   #footprintWKT: :dwc_footprint_wkt,

   #coordinateUncertaintyInMeters: :dwc_coordinate_uncertainty_in_meters,
   #geodeticDatum: :dwc_geodetic_datum,
   #georeferenceProtocol: :dwc_georeference_protocol,
   #georeferenceRemarks: :dwc_georeference_remarks,
   #georeferenceSources: :dwc_georeference_sources,
   #georeferencedBy: :dwc_georeferenced_by,
   #georeferencedDate: :dwc_georeferenced_date,
   #verbatimSRS: :dwc_verbatim_srs,

    # -- Core taxon? -- 
    # nomenclaturalCode 
    # scientificName
    # taxonmicStatus NOT DONE
    # scientificNameAuthorship
    # scientificNameID  NOT DONE
    # taxonRank
    # namePublishedIn NOT DONE
  }.freeze

  included do
  end

  # TODO: See collection_object/dwc_extensions for methods that might migrate here, 
  # particularly Taxonomy object/variable
  #
  # See lib/export/dwca/gbif_profiel/core_taxon.rb for early start

  # deprecated for new approach in CollectionObject, AssertedDistribution
  def dwca_core

    # Target fields are listed in CoreTaxon, move them here (or maybe shift everything to there ultimately as service objects)
    core = Export::Dwca::GbifProfile::CoreTaxon.new

    core.nomenclaturalCode        = (taxon_name.rank_class.nomenclatural_code.to_s.upcase)
    core.taxonomicStatus          = (taxon_name.unavailable_or_invalid? ? nil : 'accepted')
    core.nomenclaturalStatus      = (taxon_name.classification_invalid_or_unavailable? ? nil : 'available') # needs tweaking
    core.scientificName           = taxon_name.cached
    core.scientificNameAuthorship = taxon_name.cached_author_year
    core.scientificNameID         = taxon_name.identifiers.first.identifier
    core.taxonRank                = taxon_name.rank
    core.namePublishedIn          = taxon_name.source.cached
    core
  end

end
