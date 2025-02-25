module FieldOccurrence::DwcExtensions
  extend ActiveSupport::Concern

  include Shared::Dwc::CollectingEventExtensions
  include Shared::Dwc::TaxonDeterminationExtensions
  include Shared::IsDwcOccurrence

  included do

    DWC_OCCURRENCE_MAP = {
      #  catalogNumber: :dwc_catalog_number,
      #  otherCatalogNumbers: :dwc_other_catalog_numbers,
      individualCount: :dwc_individual_count,
      #  preparations: :dwc_preparations,
      lifeStage: :dwc_life_stage,
      sex: :dwc_sex,
      caste: :dwc_caste,

      country: :dwc_country,
      stateProvince: :dwc_state_province,
      county: :dwc_county,

      eventDate: :dwc_event_date,
      eventTime: :dwc_event_time,
      year: :dwc_year,
      month: :dwc_month,
      day: :dwc_day,
      startDayOfYear: :dwc_start_day_of_year,
      endDayOfYear: :dwc_end_day_of_year,

      fieldNumber: :dwc_field_number,
      maximumElevationInMeters: :dwc_maximum_elevation_in_meters,
      minimumElevationInMeters: :dwc_minimum_elevation_in_meters,
      samplingProtocol: :dwc_sampling_protocol,
      habitat: :dwc_verbatim_habitat,
      verbatimElevation: :dwc_verbatim_elevation,
      verbatimEventDate: :dwc_verbatim_event_date,
      verbatimLocality: :dwc_verbatim_locality,
      waterBody: :dwc_water_body,
      minimumDepthInMeters: :dwc_minimum_depth_in_meters,
      maximumDepthInMeters: :dwc_maximum_depth_in_meters,
      verbatimDepth: :dwc_verbatim_depth,

      recordedBy: :dwc_recorded_by, # TODO: Do we still use collector as in the data?
      recordedByID: :dwc_recorded_by_id,

      #  # Georeference "Interface'
      verbatimCoordinates: :dwc_verbatim_coordinates,
      verbatimLatitude: :dwc_verbatim_latitude,
      verbatimLongitude: :dwc_verbatim_longitude,
      decimalLatitude: :dwc_decimal_latitude,
      decimalLongitude: :dwc_decimal_longitude,
      footprintWKT: :dwc_footprint_wkt,

      coordinateUncertaintyInMeters: :dwc_coordinate_uncertainty_in_meters,
      geodeticDatum: :dwc_geodetic_datum,
      georeferenceProtocol: :dwc_georeference_protocol,
      georeferenceRemarks: :dwc_georeference_remarks,
      georeferenceSources: :dwc_georeference_sources,
      georeferencedBy: :dwc_georeferenced_by,
      georeferencedDate: :dwc_georeferenced_date,
      verbatimSRS: :dwc_verbatim_srs,

      occurrenceStatus: :dwc_occurrence_status,
      eventRemarks: :dwc_event_remarks,
      verbatimLabel: :dwc_verbatim_label,

      identifiedBy: :dwc_identified_by,
      identifiedByID: :dwc_identified_by_id,
      dateIdentified: :dwc_date_identified,
      nomenclaturalCode: :dwc_nomenclatural_code,
      kingdom: :dwc_kingdom,

      phylum: :dwc_phylum,
      dwcClass: :dwc_class,
      order: :dwc_order,
      higherClassification: :dwc_higher_classification,

      superfamily: :dwc_superfamily,
      family: :dwc_family,
      subfamily: :dwc_subfamily,
      tribe: :dwc_tribe,
      subtribe: :dwc_subtribe,
      genus: :dwc_genus,
      specificEpithet: :dwc_specific_epithet,
      infraspecificEpithet: :dwc_infraspecific_epithet,
      scientificName: :dwc_scientific_name,
      scientificNameAuthorship: :dwc_taxon_name_authorship,
      taxonRank: :dwc_taxon_rank,
      previousIdentifications: :dwc_previous_identifications,

      #  # TODO: move to a proper extension(?)
      #  associatedMedia: :dwc_associated_media,

      #  # TODO: move to a proper extension(?)
      #  associatedTaxa: :dwc_associated_taxa,

      #  occurrenceRemarks: :dwc_occurrence_remarks,
      #  identificationRemarks: :dwc_identification_remarks,

      #  # -- Core taxon? --
      #  # nomenclaturalCode
      #  # scientificName
      #  # taxonmicStatus NOT DONE
      #  # scientificNameAuthorship
      #  # scientificNameID  NOT DONE
      #  # taxonRank
      #  # namePublishedIn NOT DONE
    }.freeze
  end

  def is_fossil?
    biocuration_classes.where(uri: DWC_FOSSIL_URI).any?
  end

  def dwc_verbatim_label
    collecting_event&.verbatim_label.presence
  end

  def dwc_occurrence_status
    is_absent == true ? 'absent' : 'present'
  end

  # https://dwc.tdwg.org/list/#dwc_georeferenceRemarks
  def dwc_occurrence_remarks
    notes.collect{|n| n.text}&.join(FieldOccurrence::DWC_DELIMITER)
  end

  # https://dwc.tdwg.org/list/#dwc_identificationRemarks
  def dwc_identification_remarks
    current_taxon_determination&.notes&.collect { |n| n.text }&.join(FieldOccurrence::DWC_DELIMITER)
  end

  # https://dwc.tdwg.org/terms/#dwc:associatedMedia
  def dwc_associated_media
    images.collect{|i| api_image_link(i) }.join(FieldOccurrence::DWC_DELIMITER).presence
  end

  # https://dwc.tdwg.org/terms/#dwc:associatedtaxa
  def dwc_associated_taxa
    dwc_internal_attribute_for(:collection_object, :associatedTaxa)
  end

  # TODO: likeley a helper
  def api_image_link(image)
    s = ENV['SERVER_NAME']
    if s.nil?
      s ||= 'http://127.0.0.1:3000'
    else
      s = 'https://' + s
    end

    s = s + '/api/v1/images/' + image.image_file_fingerprint # An experiment, use md5 as a proxy for id (also unique id)
  end

  def dwc_other_catalog_numbers
    i = identifiers.where.not('type ilike ?', 'Identifier::Global::Uuid%').order(:position).to_a
    i.shift
    i.map(&:cached).join(FieldOccurrence::DWC_DELIMITER).presence
  end

  def dwc_previous_identifications
    a = taxon_determinations.order(:position).to_a
    a.shift
    a.collect{|d| ApplicationController.helpers.label_for_taxon_determination(d)}.join(FieldOccurrence::DWC_DELIMITER).presence
  end

  # TODO: normalize
  def dwc_internal_attribute_for(target = :collection_object, dwc_term_name)
    return nil if dwc_term_name.nil?

    case target
    when  :collecting_event
      return nil unless collecting_event
      collecting_event.internal_attributes.includes(:predicate)
        .where(
          controlled_vocabulary_terms: {uri: ::DWC_ATTRIBUTE_URIS[dwc_term_name.to_sym] })
        .pluck(:value)&.join(', ').presence
    when :collection_object
      internal_attributes.includes(:predicate)
        .where(
          controlled_vocabulary_terms: {uri: ::DWC_ATTRIBUTE_URIS[dwc_term_name.to_sym] })
        .pluck(:value)&.join(', ').presence
    else
      nil
    end
  end

  # TODO: consider CVT attributes with Predicates linked to URIs
  def dwc_life_stage
    biocuration_classes.tagged_with_uri(::DWC_ATTRIBUTE_URIS[:lifeStage])
      .pluck(:name)&.join(', ').presence # `.presence` is a Rails extension
  end

  # TODO: consider CVT attributes with Predicates linked to URIs
  def dwc_sex
    biocuration_classes.tagged_with_uri(::DWC_ATTRIBUTE_URIS[:sex])
      .pluck(:name)&.join(', ').presence
  end

  def dwc_caste
    biocuration_classes.tagged_with_uri(::DWC_ATTRIBUTE_URIS[:caste])
      .pluck(:name)&.join(', ').presence
  end

  def dwc_infraspecific_epithet
    %w{variety form subspecies}.each do |n| # add more as observed
      return taxonomy[n].last if taxonomy[n]
    end
    nil
  end

  def dwc_taxon_rank
    current_taxon_name&.rank
  end

  # holotype of Ctenomys sociabilis. Pearson O. P., and M. I. Christie. 1985. Historia Natural, 5(37):388, holotype of Pinus abies | holotype of Picea abies
  def dwc_type_status
    type_materials.all.collect{|t|
      ApplicationController.helpers.label_for_type_material(t)
    }.join(FieldOccurrence::DWC_DELIMITER).presence
  end

  # ISO 8601:2004(E).
  def dwc_date_identified
    current_taxon_determination&.date.presence
  end

  def dwc_higher_classification
    v = taxonomy.values.collect{|a| a.kind_of?(Array) ? a.second : a}
    v.shift
    v.pop
    v.compact
    v.join(FieldOccurrence::DWC_DELIMITER)
  end

  def dwc_kingdom
    taxonomy['kingdom']
  end

  def dwc_phylum
    taxonomy['phylum']
  end

  def dwc_class
    taxonomy['class']
  end

  def dwc_order
    taxonomy['order']
  end

  # http://rs.tdwg.org/dwc/terms/superfamily
  def dwc_superfamily
    taxonomy['superfamily']
  end

  # http://rs.tdwg.org/dwc/terms/family
  def dwc_family
    taxonomy['family']
  end

  # http://rs.tdwg.org/dwc/terms/subfamily
  def dwc_subfamily
    taxonomy['subfamily']
  end

  # http://rs.tdwg.org/dwc/terms/tribe
  def dwc_tribe
    taxonomy['tribe']
  end

  # http://rs.tdwg.org/dwc/terms/subtribe
  def dwc_subtribe
    taxonomy['subtribe']
  end

  # http://rs.tdwg.org/dwc/terms/genus
  def dwc_genus
    taxonomy['genus'] && taxonomy['genus'].compact.join(' ').presence
  end

  # http://rs.tdwg.org/dwc/terms/species
  def dwc_specific_epithet
    taxonomy['species'] && taxonomy['species'].compact.join(' ').presence
  end

  def dwc_scientific_name
    current_taxon_name.try(:cached_name_and_author_year)
  end

  def dwc_taxon_name_authorship
    current_taxon_name.try(:cached_author_year)
  end

  def dwc_institution_code
    repository.try(:acronym)
  end

  # def dwc_collection_code
  #   catalog_number_namespace&.verbatim_short_name || catalog_number_namespace&.short_name
  # end

  # def dwc_catalog_number
  #   catalog_number_cached # via delegation
  # end

  # TODO: handle ranged lots
  def dwc_individual_count
    total
  end

  def dwc_nomenclatural_code
    current_otu.try(:taxon_name).try(:nomenclatural_code)
  end

end
