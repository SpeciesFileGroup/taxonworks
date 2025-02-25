module CollectionObject::DwcExtensions

  extend ActiveSupport::Concern

  include Shared::Dwc::TaxonDeterminationExtensions
  include Shared::Dwc::CollectingEventExtensions
  include CollectionObject::DwcExtensions::TaxonworksExtensions
  include Shared::IsDwcOccurrence

  included do

    # A current list of mappable values for a CollectionObject
    # Has order is semi-useful for quick reporting
    DWC_OCCURRENCE_MAP = {
      catalogNumber: :dwc_catalog_number,
      recordNumber: :dwc_record_number,
      otherCatalogNumbers: :dwc_other_catalog_numbers,
      individualCount: :dwc_individual_count,
      preparations: :dwc_preparations,
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
      eventID: :dwc_event_id,

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

      typeStatus: :dwc_type_status,

      institutionCode: :dwc_institution_code,
      institutionID: :dwc_institution_id,

      recordedBy: :dwc_recorded_by,
      recordedByID: :dwc_recorded_by_id,

      # Georeference "Interface'
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

      # TODO: move to a proper extension(?)
      associatedMedia: :dwc_associated_media,

      # TODO: move to a proper extension(?)
      associatedTaxa: :dwc_associated_taxa,

      occurrenceRemarks: :dwc_occurrence_remarks,

      identificationRemarks: :dwc_identification_remarks,

      eventRemarks: :dwc_event_remarks,

      verbatimLabel: :dwc_verbatim_label,

      # -- Core taxon? --
      # nomenclaturalCode
      # scientificName
      # taxonmicStatus NOT DONE
      # scientificNameAuthorship
      # scientificNameID  NOT DONE
      # taxonRank
      # namePublishedIn NOT DONE
    }.freeze

    # verbatim label data

  end

  # use buffered if any
  # if not check CE verbatim_label
  def dwc_verbatim_label
    b = [buffered_collecting_event, buffered_determinations, buffered_other_labels].compact
    return  b.join("\n\n") if b.present?
    collecting_event&.verbatim_label.presence
  end

  def dwc_occurrence_status
    'present'
  end

  # https://dwc.tdwg.org/list/#dwc_georeferenceRemarks
  def dwc_occurrence_remarks
    notes.collect{|n| n.text}&.join(CollectionObject::DWC_DELIMITER).presence
  end

  # https://dwc.tdwg.org/terms/#dwc:associatedMedia
  def dwc_associated_media
    images.collect{|i| api_image_link(i) }.join(CollectionObject::DWC_DELIMITER).presence
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

  # TODO: optimize by finding all relevant identifiers in one query, then looping through them

  def dwc_collection_code
    catalog_number_namespace&.verbatim_short_name || catalog_number_namespace&.short_name
  end

  def dwc_record_number
    record_number_cached # via delegation
  end

  def dwc_catalog_number
    catalog_number_cached # via delegation
  end

  def dwc_other_catalog_numbers
    i = identifiers.where.not('type ilike ?', 'Identifier::Global::Uuid%').order(:position).to_a
    i.shift
    i.map(&:cached).join(CollectionObject::DWC_DELIMITER).presence
  end


  # TODO: duplicated in CE extension
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

  # Perhaps: Create an optimized data structure that
  # elminates need for multiple queries.  Below
  # does not work because we can't retroactively
  # inspect the Keyword for the specific match.

  # attr_accessor :target_biocuration_classes

  # def target_biocuration_classes
  #   @target_biocuratoin_classes ||= biocuration_classes.tagged_with_uri(
  #     [
  #       ::DWC_ATTRIBUTE_URIS[:lifeStage],
  #       ::DWC_ATTRIBUTE_URIS[:sex],
  #       ::DWC_ATTRIBUTE_URIS[:caste],
  #       DWC_FOSSIL_URI
  #     ]
  #   )
  # end

  # def biocuration_class_for(uri)
  #   target_biocuration_classes.select{|a| a.keyword.uri == uri}
  #     .collect{|b| b.name}.join(', ').presence
  # end

  # TODO: consider CVT attributes with Predicates linked to URIs
  def dwc_life_stage
    biocuration_classes.tagged_with_uri(::DWC_ATTRIBUTE_URIS[:lifeStage])
      .pluck(:name)&.join(', ').presence # `.presence` is a Rails extension
  end

  # TODO: consider CVT attributes with Predicates linked to URIs
  def dwc_sex
    biocuration_classes.tagged_with_uri(::DWC_ATTRIBUTE_URIS[:sex])
      .pluck(:name)&.join(', ').presence # TODO: Use delimeter!
  end

  def dwc_caste
    biocuration_classes.tagged_with_uri(::DWC_ATTRIBUTE_URIS[:caste])
      .pluck(:name)&.join(', ').presence #  TODO: Use delimeter!
  end

  def is_fossil?
    biocuration_classes.where(uri: DWC_FOSSIL_URI).any?
  end

  # holotype of Ctenomys sociabilis. Pearson O. P., and M. I. Christie. 1985. Historia Natural, 5(37):388, holotype of Pinus abies | holotype of Picea abies
  def dwc_type_status
    type_materials.all.collect{|t|
      ApplicationController.helpers.label_for_type_material(t)
    }.join(CollectionObject::DWC_DELIMITER).presence
  end

  def dwc_higher_classification
    v = taxonomy.values.collect{|a| a.kind_of?(Array) ? a.second : a}
    v.shift
    v.pop
    v.compact
    v.join(CollectionObject::DWC_DELIMITER).presence
  end

  # Definition: A list (concatenated and separated) of names of people, groups, or organizations responsible for recording the original Occurrence. The primary collector or observer, especially one who applies a personal identifier (recordNumber), should be listed first.

  # we assert custody, NOT ownership
  def dwc_institution_code
    repository_acronym
  end

  # we assert custody, NOT ownership
  def dwc_institution_id
    # TODO: identifiers on Repositories
    repository_url || repository_institutional_LSID
  end

  # TODO: handle ranged lots
  def dwc_individual_count
    total
  end

  def dwc_event_time
    return unless collecting_event

    %w{start_time end_time}
      .map { |t| %w{hour minute second}
      .map { |p| collecting_event["#{t}_#{p}"] }
      .map { |p| '%02d' % p if p } # At least two digits
      }
        .map { |t| t.compact.join(':') }
        .reject(&:blank?)
        .join('/').presence
  end

  def dwc_preparations
    preparation_type_name
  end

end
