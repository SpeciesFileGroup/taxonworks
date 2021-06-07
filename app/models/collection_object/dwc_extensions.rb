module CollectionObject::DwcExtensions

  extend ActiveSupport::Concern

  # A current list of mappable values
  DWC_OCCURRENCE_MAP = {
    catalogNumber: :dwc_catalog_number,
    country: :dwc_country,
    county: :dwc_county,
    dateIdentified: :dwc_date_identified,
    eventDate: :dwc_event_date,
    eventTime: :dwc_event_time,
    family: :dwc_family,
    fieldNumber: :dwc_field_number,
    genus: :dwc_genus,
    habitat: :dwc_verbatim_habitat,
    identifiedBy: :dwc_identified_by,
    identifiedByID: :dwc_identified_by_id,
    individualCount: :dwc_individual_count,
    infraspecificEpithet: :dwc_infraspecific_epithet,
    institutionCode: :dwc_institution_code,
    institutionID: :dwc_institution_id,
    kingdom: :dwc_kingdom,
    lifeStage: :dwc_life_stage,
    maximumElevationInMeters: :dwc_maximum_elevation_in_meters,
    minimumElevationInMeters: :dwc_minimum_elevation_in_meters,
    nomenclaturalCode: :dwc_nomenclatural_code,
    otherCatalogNumbers: :dwc_other_catalog_numbers,
    preparations: :dwc_preparations,
    previousIdentifications: :dwc_previous_identifications,
    recordedBy: :dwc_recorded_by,  
    recordedByID: :dwc_recorded_by_id,
    samplingProtocol: :dwc_sampling_protocol,
    scientificName: :dwc_scientific_name,
    scientificNameAuthorship: :dwc_taxon_name_authorship,
    sex: :dwc_sex,
    specificEpithet: :dwc_specific_epithet,
    stateProvince: :dwc_state_province,
    taxonRank: :dwc_taxon_rank,
    typeStatus: :dwc_type_status,
    verbatimElevation: :dwc_verbatim_elevation,
    verbatimEventDate: :dwc_verbatim_event_date,
    verbatimLocality: :dwc_verbatim_locality,
    waterBody: :dwc_water_body,
    
    # Georeference "Interface'
    verbatimCoordinates: :dwc_verbatim_coordinates,
    verbatimLatitude: :dwc_verbatim_latitude,
    verbatimLongitude: :dwc_verbatim_longitude,
    decimalLatitude: :dwc_latitude,
    decimalLongitude: :dwc_longitude,

    footprintWKT: :dwc_footprint_wkt,

    coordinateUncertaintyInMeters: :dwc_coordinate_uncertainty_in_meters,
    geodeticDatum: :dwc_geodetic_datum,
    georeferenceProtocol: :dwc_georeference_protocol,
    georeferenceRemarks: :dwc_georeference_remarks,
    georeferenceSources: :dwc_georeference_sources,
    georeferencedBy: :dwc_georeferenced_by,
    georeferencedDate: :dwc_georeferenced_date,
    verbatimSRS: :dwc_verbatim_srs,

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
    attr_accessor :georeference_attributes

    # @return [Hash]
    # getter returning georeference related attributes
    def georeference_attributes
      @georeference_attributes ||= set_georeference_attributes
    end
  end

  # @return [Hash]
  def set_georeference_attributes
    case collecting_event&.dwc_georeference_source
    when :georeference 
      collecting_event.preferred_georeference.dwc_georeference_attributes
    when :verbatim
      h = collecting_event.dwc_georeference_attributes

      if a = collecting_event&.attribute_updater(:verbatim_latitude)
        h[:georeferencedBy] = User.find(a).name
      end

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

  # georeferenceDate
  # technically could look at papertrail to see when geographic_area_id appeared
  def dwc_georeferenced_date
    collecting_event&.attribute_updated(:geographic_area_id)
  end

  def dwc_geodetic_datum
    georeference_attributes[:geodetic_datum]
  end

  def dwc_verbatim_srs
    georeference_attributes[:dwc_verbatim_srs]
  end

  # TODO: extend to Georeferences when we understand how to describe spatial uncertainty
  def dwc_coordinate_uncertainty_in_meters
    collecting_event&.verbatim_geolocation_uncertainty
  end

  def dwc_verbatim_latitude
    collecting_event&.verbatim_latitude
  end

  def dwc_verbatim_longitude
    collecting_event&.verbatim_longitude
  end

  def dwc_other_catalog_numbers
    i = identifiers.order(:position).to_a
    i.shift
    i.map(&:cached).join(' | ').presence
  end

  def dwc_previous_identifications
    a = taxon_determinations.order(:position).to_a
    a.shift
    a.collect{|d| ApplicationController.helpers.label_for_taxon_determination(d)}.join(' | ').presence
  end

  def dwc_water_body
    return nil unless collecting_event
    collecting_event.internal_attributes.includes(:predicate) 
      .where(
        controlled_vocabulary_terms: {uri: DWC_ATTRIBUTE_URIS[:waterBody] })
      .pluck(:value)&.join(', ').presence
  end

  # TODO: consider CVT attributes with predicates linked to URIs
  def dwc_life_stage
    biocuration_classes
      .where(
        controlled_vocabulary_terms: {uri: DWC_ATTRIBUTE_URIS[:lifeStage] })
      .pluck(:name)&.join(', ').presence # `.presence` is a Rails extension
  end

  # TODO: consider CVT attributes with predicates linked to URIs
  def dwc_sex
    biocuration_classes
      .where(
        controlled_vocabulary_terms: {uri: DWC_ATTRIBUTE_URIS[:sex] })
      .pluck(:name)&.join(', ').presence
  end

  def dwc_verbatim_coordinates
    return nil unless collecting_event
    [collecting_event.verbatim_latitude, collecting_event.verbatim_latitude].compact.join(' ').presence
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
    collecting_event.identifiers.where(type: 'Identifier::Local::TripCode').first&.cached
  end

  def dwc_verbatim_habitat
    collecting_event&.verbatim_habitat
  end

  def dwc_verbatim_event_date
    collecting_event&.verbatim_date
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
    }.join(' | ').presence
  end

  # ISO 8601:2004(E).
  def dwc_date_identified
    current_taxon_determination&.date
  end

  attr_accessor :taxonomy

  # @params reset [Boolean]
  # @return [Hash]
  # 
  # Using `.reload` will not reset taxonomy!
  def taxonomy(reset = false)
    if reset
      reload
      @taxonomy = set_taxonomy
    else
    @taxonomy ||= set_taxonomy
  end
  end

  def dwc_kingdom
    taxonomy['kingdom']
  end

  # http://rs.tdwg.org/dwc/terms/family
  def dwc_family
    taxonomy['family']
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

  # Definition: A list (concatenated and separated) of names of people, groups, or organizations responsible for recording the original Occurrence. The primary collector or observer, especially one who applies a personal identifier (recordNumber), should be listed first.
  #
  # This is, frankly, a worthless field. Currently populated with Determiners, ordered by preferred, then historical, then collectors tossed in for good measure. Maybe we can add the
  # people who digitally captured all the different components of the graph too. 
  def dwc_recorded_by
    # TODO: raw SQL this mess?
    ( determiners.includes(:roles).order('taxon_determinations.position, roles.position').to_a + 
     (collecting_event ? collecting_event&.collectors.includes(:roles).order('roles.position').to_a : [])) 
      .uniq.map(&:cached).join(' | ').presence
  end 

  def dwc_recorded_by_id
    # TODO: raw SQL this mess?
    ( determiners.includes(:roles).order('taxon_determinations.position, roles.position').to_a + 
     (collecting_event ? collecting_event&.collectors.includes(:roles).order('roles.position').to_a : [])) 
      .uniq.map(&:orcid).join(' | ').presence
  end 

  def dwc_identified_by
    # TaxonWorks allows for groups of determiners to collaborate on a single determination if they collectively came to a conclusion.
    current_taxon_determination&.determiners&.map(&:cached)&.join(' | ').presence
  end

  def dwc_identified_by_id
    # TaxonWorks allows for groups of determiners to collaborate on a single determination if they collectively came to a conclusion.
    current_taxon_determination&.determiners&.map(&:orcid)&.join(' | ').presence
  end

  def dwc_institution_code
    repository.try(:acronym)
  end

  def dwc_catalog_number
    catalog_number_cached
  end

  # TODO: handle ranged lots
  def dwc_individual_count
    total
  end

  def dwc_country
    v = try(:collecting_event).try(:geographic_name_classification)
    v[:country] if v
  end

  def dwc_state_province
    v = try(:collecting_event).try(:geographic_name_classification)
    v[:state] if v
  end

  def dwc_county
    v = try(:collecting_event).try(:geographic_name_classification)
    v[:county] if v
  end

  def dwc_locality
    collecting_event.try(:verbatim_locality)
  end

  def dwc_latitude
    collecting_event_map_center.try(:y)
  end

  def dwc_longitude
    collecting_event_map_center.try(:x)
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
        .map { |p| "%02d" % p if p } # At least two digits
      }
      .map { |t| t.compact.join(':') }
      .reject(&:blank?)
      .join("/").presence
  end

  def dwc_event_date
    return unless collecting_event

    %w{start_date end_date}
      .map { |d| %w{year month day}
        .map { |p| collecting_event["#{d}_#{p}"] }
        .map { |p| "%02d" % p if p } # At least two digits
      }
      .map { |d| d.compact.join('-') }
      .reject(&:blank?)
      .join("/").presence
  end

  def dwc_preparations
    preparation_type_name
  end

  # we assert custody, NOT ownership
  def dwc_institution_code
    repository_acronym
  end

  # we assert custody, NOT ownership
  def dwc_institution_id
    repository_url
  end

  def dwc_georeference_protocol
    case collecting_event.try(:lat_lon_source)
    when :georeference
      preferred_georeference.type.tableize.humanize # Can expand with Georeference#description possibly
    when :verbatim
      'Verbatim'
    when :geographic_area
      'Geographic area shape centroid.'  # TODO: standardize
    else
      nil
    end
  end

  protected

  def set_taxonomy
    c = self.current_taxon_name
    # If we have no name, see if there is a Type reference and use it as proxy
    c ||= type_materials.primary.first&.protonym 

    if c 
      @taxonomy = c.full_name_hash
      # Check for required 'Kingdom'
      if @taxonomy['kingdom'].blank?

        # Det is only to kingdom!
        if c.rank == 'kingdom'
          @taxonomy['kingdom'] = c.name
        else

          # Kindom is provided in ancestors
          if a = c.ancestor_at_rank(:kingdom)
            @taxonomy['kingdom'] = a.name
          else

            # Very edge case for single kingom nomenclatures (almost none)
            if c.rank_class::KINGDOM.size == 1
              @taxonomy['kingdom'] = c.rank_class::KINGDOM.first
            end
          end
        end
      end
      @taxonomy
    else
      @taxonomy ||= {}
    end
  end

end
