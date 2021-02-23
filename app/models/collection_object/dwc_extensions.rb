module CollectionObject::DwcExtensions

  DWC_OCCURRENCE_MAP = {
    catalogNumber: :dwc_catalog_number,
    family: :dwc_family,
    genus: :dwc_genus,
    specificEpithet: :dwc_specific_epithet,
    scientificName: :dwc_scientific_name,
    scientificNameAuthorship: :dwc_taxon_name_authorship,
    country: :dwc_country,
    stateProvince: :dwc_state_province,
    county: :dwc_county,
    decimalLatitude: :dwc_latitude,
    decimalLongitude: :dwc_longitude,
    georeferenceProtocol: :dwc_georeference_protocol,
    verbatimLocality: :dwc_verbatim_locality,
    nomenclaturalCode: :dwc_nomenclatural_code,
    eventTime: :dwc_event_time,
    eventDate: :dwc_event_date,
    preparations: :dwc_preparations,
    institutionCode: :dwc_institution_code,
    institutionID: :dwc_institution_id,
    recordedBy: :dwc_recorded_by,  
    individualCount: :dwc_individual_count,
  }.freeze

  attr_accessor :taxonomy

  def taxonomy
    @taxonomy ||= set_taxonomy
  end

  # http://rs.tdwg.org/dwc/terms/family
  def dwc_family
    taxonomy['family']
  end

  # http://rs.tdwg.org/dwc/terms/genus
  def dwc_genus
    taxonomy['genus'] && taxonomy['genus'].compact.join(' ')
  end

  # http://rs.tdwg.org/dwc/terms/species
  def dwc_specific_epithet
    taxonomy['species'] && taxonomy['species'].compact.join(' ')
  end

  def dwc_scientific_name
    current_taxon_name.try(:cached_name_and_author_year)
  end

  def dwc_taxon_name_authorship
    current_taxon_name.try(:cached_author_year)
  end

  # !! lots of try now, see :delegate as a possible refactor - http://api.rubyonrails.org/classes/Module.html#method-i-delegate

  def dwc_recorded_by
    collecting_event.try(:collectors_string)
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
      .join("/")
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
      .join("/")
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
    if self.current_taxon_name
      @taxonomy = self.current_taxon_name.full_name_hash
    else
      @taxonomy ||= {}
    end
  end

end

