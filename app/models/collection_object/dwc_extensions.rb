module CollectionObject::DwcExtensions

  extend ActiveSupport::Concern

  include CollectionObject::DwcExtensions::TaxonworksExtensions

  included do

    # A current list of mappable values
    # Even though it is a Hash it maintains key order, which is
    # semi-useful for quick reporting.
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

    attr_accessor :georeference_attributes
    attr_accessor :target_taxon_name

    def target_taxon_name
      @target_taxon_name ||= current_valid_taxon_name
    end

    # @return [Hash]
    # getter returning georeference related attributes
    def georeference_attributes(force = false)
      if force
        @georeference_attributes = set_georeference_attributes
      else
        @georeference_attributes ||= set_georeference_attributes
      end
    end
  end

  # @return [Hash]
  #
  def set_georeference_attributes
    case collecting_event&.dwc_georeference_source
    when :georeference
      collecting_event.preferred_georeference.dwc_georeference_attributes
    when :verbatim
      h = collecting_event.dwc_georeference_attributes

      # Our interpretation is now that georeferencedBy is the person who "computed" the
      # values, not transcribed the values.
      #
      #     if a = collecting_event&.attribute_updater(:verbatim_latitude)
      #       h[:georeferencedBy] = User.find(a).name
      #     end

      # verbatim_longitude could technically be different, but...
      h[:georeferencedDate] = collecting_event&.attribute_updated(:verbatim_latitude)

      h

    when :geographic_area
      h = collecting_event.geographic_area.dwc_georeference_attributes
      if a = collecting_event&.attribute_updater(:geographic_area_id)
        h[:georeferencedBy] = User.find(a).name
      end

      h[:georeferencedDate] = collecting_event&.attribute_updated(:geographic_area_id)

      h
    else
      {}
    end
  end


  def is_fossil?
    biocuration_classes.where(uri: DWC_FOSSIL_URI).any?
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
    notes.collect{|n| n.text}&.join(CollectionObject::DWC_DELIMITER)
  end

  # https://dwc.tdwg.org/list/#dwc_identificationRemarks
  def dwc_identification_remarks
    current_taxon_determination&.notes&.collect { |n| n.text }&.join(CollectionObject::DWC_DELIMITER)
  end

  def dwc_event_remarks
    collecting_event&.notes&.collect {|n| n.text}&.join(CollectionObject::DWC_DELIMITER)
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

  def dwc_georeference_sources
    georeference_attributes[:georeferenceSources]
  end

  def dwc_georeference_remarks
    georeference_attributes[:georeferenceRemarks]
  end

  def dwc_footprint_wkt
    georeference_attributes[:footprintWKT]
  end

  def dwc_georeferenced_by
    georeference_attributes[:georeferencedBy]
  end

  def dwc_georeferenced_date
    georeference_attributes[:georeferencedDate]
  end

  def dwc_geodetic_datum
    georeference_attributes[:geodeticDatum]
  end

  def dwc_verbatim_srs
    georeference_attributes[:dwcVerbatimSrs]
  end

  # georeferenceDate
  # technically could look at papertrail to see when geographic_area_id appeared
  def dwc_georeferenced_date
    collecting_event&.attribute_updated(:geographic_area_id)
  end

  # TODO: extend to Georeferences when we understand how to describe spatial uncertainty
  def dwc_coordinate_uncertainty_in_meters
    if georeference_attributes[:coordinateUncertaintyInMeters]
      georeference_attributes[:coordinateUncertaintyInMeters]
    else
      collecting_event&.verbatim_geolocation_uncertainty
    end
  end

  def dwc_verbatim_latitude
    collecting_event&.verbatim_latitude
  end

  def dwc_verbatim_longitude
    collecting_event&.verbatim_longitude
  end

  def dwc_other_catalog_numbers
    i = identifiers.where.not('type ilike ?', 'Identifier::Global::Uuid%').order(:position).to_a
    i.shift
    i.map(&:cached).join(CollectionObject::DWC_DELIMITER).presence
  end

  def dwc_previous_identifications
    a = taxon_determinations.order(:position).to_a
    a.shift
    a.collect{|d| ApplicationController.helpers.label_for_taxon_determination(d)}.join(CollectionObject::DWC_DELIMITER).presence
  end

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

  def dwc_water_body
    dwc_internal_attribute_for(:collecting_event, :waterBody)
  end

  def dwc_minimum_depth_in_meters
    dwc_internal_attribute_for(:collecting_event, :minimumDepthInMeters)
  end

  def dwc_maximum_depth_in_meters
    dwc_internal_attribute_for(:collecting_event, :maximumDepthInMeters)
  end

  def dwc_verbatim_depth
    dwc_internal_attribute_for(:collecting_event, :verbatimDepth)
  end

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

  def dwc_verbatim_coordinates
    return nil unless collecting_event
    [collecting_event.verbatim_latitude, collecting_event.verbatim_longitude].compact.join(' ').presence
  end

  def dwc_verbatim_elevation
    collecting_event&.verbatim_elevation
  end

  def dwc_maximum_elevation_in_meters
    collecting_event&.maximum_elevation
  end

  def dwc_minimum_elevation_in_meters
    collecting_event&.minimum_elevation
  end

  # TODO: Reconcile with Protocol (capital P) assignments
  def dwc_sampling_protocol
    collecting_event&.verbatim_method
  end

  def dwc_field_number
    return nil unless collecting_event
    # Since we enforce that they are identical we can choose the former if present
    collecting_event&.verbatim_trip_identifier || collecting_event.identifiers.where(type: 'Identifier::Local::FieldNumber').first&.cached
  end

  def dwc_event_id
    return nil unless collecting_event
    collecting_event.identifiers.where(type: 'Identifier::Local::Event').first&.cached.presence
  end

  def dwc_verbatim_habitat
    collecting_event&.verbatim_habitat
  end

  def dwc_infraspecific_epithet
    %w{variety form subspecies}.each do |n| # add more as observed
      return taxonomy[n].last if taxonomy[n]
    end
    nil
  end

  def dwc_taxon_rank
    target_taxon_name&.rank
  end

  # holotype of Ctenomys sociabilis. Pearson O. P., and M. I. Christie. 1985. Historia Natural, 5(37):388, holotype of Pinus abies | holotype of Picea abies
  def dwc_type_status
    type_materials.all.collect{|t|
      ApplicationController.helpers.label_for_type_material(t)
    }.join(CollectionObject::DWC_DELIMITER).presence
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
    v.join(CollectionObject::DWC_DELIMITER).presence
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
    target_taxon_name&.cached_name_and_author_year
  end

  def dwc_taxon_name_authorship
    target_taxon_name&.cached_author_year
  end

  # Definition: A list (concatenated and separated) of names of people, groups, or organizations responsible for recording the original Occurrence. The primary collector or observer, especially one who applies a personal identifier (recordNumber), should be listed first.
  #
  # This was interpreted as collectors (in the field in this context), not those who recorded other aspects of the data.
  def dwc_recorded_by
    v = nil
    if collecting_event
      v = collecting_event.collectors
        .order('roles.position')
        .map(&:name)
        .join(CollectionObject::DWC_DELIMITER)
        .presence
      v = collecting_event.verbatim_collectors.presence if v.blank?
    end
    v
  end

  # See dwc_recorded_by
  # TODO: Expand to any GlobalIdentifier
  def dwc_recorded_by_id
    if collecting_event
      collecting_event.collectors
        .joins(:identifiers)
        .where(identifiers: {type: ['Identifier::Global::Orcid', 'Identifier::Global::Wikidata']})
        .select('identifiers.identifier_object_id, identifiers.cached')
        .unscope(:order)
        .distinct
        .pluck('identifiers.cached')
        .join(CollectionObject::DWC_DELIMITER)&.presence
    end
  end

  def dwc_identified_by
    # TaxonWorks allows for groups of determiners to collaborate on a single determination if they collectively came to a conclusion.
    current_taxon_determination&.determiners&.map(&:name)&.join(CollectionObject::DWC_DELIMITER).presence
  end

  def dwc_identified_by_id
    # TaxonWorks allows for groups of determiners to collaborate on a single determination if they collectively came to a conclusion.
    if current_taxon_determination
      current_taxon_determination&.determiners
        .joins(:identifiers)
        .where(identifiers: {type: ['Identifier::Global::Orcid', 'Identifier::Global::Wikidata']})
        .select('identifiers.identifier_object_id, identifiers.cached')
        .unscope(:order)
        .distinct
        .pluck('identifiers.cached')
        .join(CollectionObject::DWC_DELIMITER)&.presence
    end
  end

  # we assert custody, NOT ownership
  def dwc_institution_code
    repository_acronym
  end

  # we assert custody, NOT ownership
  def dwc_institution_id
    # TODO: identifiers on Repositories
    repository_url || repository_institutional_LSID
  end

  def dwc_collection_code
    catalog_number_namespace&.verbatim_short_name || catalog_number_namespace&.short_name
  end

  def dwc_record_number
    record_number_cached # via delegation
  end

  def dwc_catalog_number
    catalog_number_cached # via delegation
  end

  # TODO: handle ranged lots
  def dwc_individual_count
    total
  end

  def dwc_country
    v = try(:collecting_event).try(:geographic_names)
    v[:country] if v
  end

  def dwc_state_province
    v = try(:collecting_event).try(:geographic_names)
    v[:state] if v
  end

  def dwc_county
    v = try(:collecting_event).try(:geographic_names)
    v[:county] if v
  end

  def dwc_locality
    collecting_event.try(:verbatim_locality)
  end

  def dwc_decimal_latitude
    georeference_attributes[:decimalLatitude]
  end

  def dwc_decimal_longitude
    georeference_attributes[:decimalLongitude]
  end

  def dwc_verbatim_locality
    collecting_event.try(:verbatim_locality)
  end

  def dwc_nomenclatural_code
    current_otu.try(:taxon_name).try(:nomenclatural_code)
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

  def dwc_verbatim_event_date
    collecting_event&.verbatim_date
  end

  def dwc_event_date
    return unless collecting_event

    %w{start_date end_date}
      .map { |d| %w{year month day}
      .map { |p| collecting_event["#{d}_#{p}"] }
      .map { |p| '%02d' % p if p } # At least two digits
      }
        .map { |d| d.compact.join('-') }
        .reject(&:blank?)
        .join('/').presence
  end

  def dwc_year
    return unless collecting_event
    collecting_event.start_date_year.presence
  end

  def dwc_month
    return unless collecting_event
    collecting_event.start_date_month.presence
  end

  def dwc_day
    return unless collecting_event
    collecting_event.start_date_day.presence
  end

  def dwc_start_day_of_year
    return unless collecting_event
    collecting_event.start_day_of_year.presence
  end

  def dwc_end_day_of_year
    return unless collecting_event
    collecting_event.end_day_of_year.presence
  end

  def dwc_preparations
    preparation_type_name
  end

  def dwc_georeference_protocol
    georeference_attributes[:georeferenceProtocol]
  end

end
