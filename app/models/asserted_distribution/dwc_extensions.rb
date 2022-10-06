module AssertedDistribution::DwcExtensions

  extend ActiveSupport::Concern

  DWC_OCCURRENCE_MAP = {
    associatedReferences: :dwc_associated_references,
    country: :dwc_country,
    county: :dwc_county,
    occurrenceStatus: :dwc_occurrence_status,
    stateProvince: :dwc_state_province,


    kingdom: :dwc_kingdom,
    family: :dwc_family,
    genus: :dwc_genus,
    specificEpithet: :dwc_specific_epithet,
    infraspecificEpithet: :dwc_infraspecific_epithet,
    scientificName: :dwc_scientific_name,
    scientificNameAuthorship: :dwc_taxon_name_authorship,
    taxonRank: :dwc_taxon_rank,
  }.freeze

  attr_accessor :geographic_names

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

  def dwc_infraspecific_epithet
    %w{variety form subspecies}.each do |n| # add more as observed
      return taxonomy[n].last if taxonomy[n]
    end
    nil
  end

  def dwc_scientific_name
    otu.taxon_name&.valid_taxon_name&.cached_name_and_author_year
  end

  def dwc_taxon_name_authorship
    otu.taxon_name&.valid_taxon_name&.cached_author_year
  end

  def dwc_taxon_rank
    otu.taxon_name&.valid_taxon_name&.rank
  end

  # TODO: If this is altered there are implications for sources section in PaperCatalog.
  def dwc_associated_references
    sources.order(:cached_nomenclature_date).map(&:cached).uniq.join(AssertedDistribution::DWC_DELIMITER)
  end

  def dwc_occurrence_status
    is_absent ? 'absent' : 'present'
  end

  def dwc_country
    geographic_names[:country]
  end

  def dwc_state_province
    geographic_names[:state]
  end

  def dwc_county
    geographic_names[:county]
  end

  # At present we are not exporting the spatial footprint
  # See also app/models/geographic_area/dwc_serialization.rb
  #
  # attr_accessor :geospatial_attributes
  #
  # # @return [Hash]
  # # getter returning georeference related attributes
  # def geospatial_attributes(force = false)
  #   if force
  #     @geospatial_attributes = set_geospatial_attributes
  #   else
  #     @geospatial_attributes ||= set_geospatial_attributes
  #   end
  # end
  #
  # # @return [Hash]
  # #
  # def set_geospatial_attributes
  #   h = geographic_area.dwc_georeference_attributes
  #   if a = attribute_updater(:geographic_area_id)
  #     h[:georeferencedBy] = User.find(a).name
  #   end
  #
  #   h[:georeferencedDate] = updated_at
  #
  #   h
  # end


end
