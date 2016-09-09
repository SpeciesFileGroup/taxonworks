module Dwca::CollectionObjectExtensions

  attr_accessor :taxonomy

  def taxonomy
    @taxonomy ||= set_taxonomy
  end

  # http://rs.tdwg.org/dwc/terms/basisOfRecord
  def dwca_basis_of_record
    'Preserved Specimen'
  end

  # http://rs.tdwg.org/dwc/terms/family
  def dwca_family
    taxonomy['family']
  end

  # http://rs.tdwg.org/dwc/terms/genus
  def dwca_genus
    taxonomy['genus'] && taxonomy['genus'].compact.join(" ")
  end

  # http://rs.tdwg.org/dwc/terms/species
  def dwca_species
    taxonomy['species'] && taxonomy['species'].compact.join(" ")
  end

  def dwca_catalog_number
    preferred_catalog_number.try(:cached)
  end

  # def dwca_latitude
  #   try(:collecting_event).try(:verbatim_latitude)
  # end
  #
  # def dwca_latitude
  #   try(:collecting_event).try(:verbatim_longitude)
  # end

  def dwca_country
    v = try(:collecting_event).try(:geographic_name_classification)
    v[:country] if v
  end

  def dwca_state
    v = try(:collecting_event).try(:geographic_name_classification)
    v[:state] if v
  end

  def dwca_county
    v = try(:collecting_event).try(:geographic_name_classification)
    v[:county] if v
  end

  def dwca_locality
    try(:collecting_event).try(:verbatim_locality)
  end

  def dwca_latitude
    try(:collecting_event).try(:map_center).try(:y)
  end

  def dwca_longitude
    try(:collecting_event).try(:map_center).try(:x)
  end

  def dwca_precision

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

