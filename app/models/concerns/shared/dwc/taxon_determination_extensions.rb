# Shared code for TaxonDetermination serialization into DwcOccurrence records
module Shared::Dwc::TaxonDeterminationExtensions
  extend ActiveSupport::Concern

  included do
    # Populated in individual models.
    attr_accessor :target_taxon_determination

    attr_accessor :target_taxon_name

    def target_taxon_name
      @target_taxon_name ||= current_valid_taxon_name
    end

    def target_taxon_determination
      @target_taxon_determination ||= current_taxon_determination
    end
  end

  # ISO 8601:2004(E).
  def dwc_date_identified
    target_taxon_determination&.date.presence
  end

  def dwc_identified_by
    # TaxonWorks allows for groups of determiners to collaborate on a single determination if they collectively came to a conclusion.
    target_taxon_determination&.determiners&.map(&:name)&.join(CollectionObject::DWC_DELIMITER).presence
  end

  def dwc_identified_by_id
    # TaxonWorks allows for groups of determiners to collaborate on a single determination if they collectively came to a conclusion.
    if target_taxon_determination
      target_taxon_determination&.determiners
        .joins(:identifiers)
        .where(identifiers: {type: ['Identifier::Global::Orcid', 'Identifier::Global::Wikidata']})
        .select('identifiers.identifier_object_id, identifiers.cached')
        .unscope(:order)
        .distinct
        .pluck('identifiers.cached')
        .join(CollectionObject::DWC_DELIMITER)&.presence
    end
  end

  # https://dwc.tdwg.org/list/#dwc_identificationRemarks
  def dwc_identification_remarks
    target_taxon_determination&.notes&.collect{ |n| n.text }&.join(CollectionObject::DWC_DELIMITER).presence
  end

  def dwc_previous_identifications
    a = taxon_determinations.order(:position).to_a
    a.shift
    a.collect{|d| ApplicationController.helpers.label_for_taxon_determination(d)}.join(CollectionObject::DWC_DELIMITER).presence
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

  def dwc_nomenclatural_code
    current_otu.try(:taxon_name).try(:nomenclatural_code)
  end

end
