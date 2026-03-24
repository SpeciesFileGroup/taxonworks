# CSV for Species Distribution extension (for checklist archives)
# See http://rs.gbif.org/extension/gbif/1.0/distribution.xml
#
module Export::CSV::Dwc::Extension::Checklist::SpeciesDistribution

  GBIF = Export::Dwca::GbifProfile::SpeciesDistribution

  # Fields used in checklist exports (subset of full GBIF profile).
  CHECKLIST_FIELDS = [
    :id, # Required for DwC-A star joins (taxonID, an OTU UUID)
    GBIF::LOCALITY,
    GBIF::OCCURRENCE_STATUS,
    GBIF::SOURCE
  ].freeze

  HEADERS = CHECKLIST_FIELDS

  HEADERS_NAMESPACES = CHECKLIST_FIELDS.map do |field|
    field == :id ? '' : GBIF::NAMESPACES[field]
  end.freeze

  # Generate CSV for species distribution extension.
  # @param scope [ActiveRecord::Relation] DwcOccurrence records from
  #   AssertedDistribution
  # @param taxon_name_id_to_taxon_id [Hash] taxon_name_id => OTU UUID (used as dwc:taxonID in the checklist core)
  # @return [String] CSV content
  def self.csv(scope, taxon_name_id_to_taxon_id)
    tbl = []
    tbl[0] = HEADERS

    otu_to_taxon_name_id = scope
      .joins('JOIN otus ON otus.id = dwc_occurrences.otu_id')
      .joins('JOIN taxon_names ON taxon_names.id = otus.taxon_name_id')
      .pluck(
        Arel.sql('dwc_occurrences.otu_id'),
        Arel.sql('COALESCE(taxon_names.cached_valid_taxon_name_id, taxon_names.id)')
      )
      .to_h

    scope.find_each do |dwc_occ|
      # Use locality field if populated (for regional areas like "West Tropical Africa"),
      # otherwise build from country/state/county.
      locality = dwc_occ.locality.presence || begin
        locality_parts = [
          dwc_occ.country,
          dwc_occ.stateProvince,
          dwc_occ.county
        ].compact.reject(&:empty?)
        locality_parts.join(', ').presence
      end

      taxon_name_id = otu_to_taxon_name_id[dwc_occ.otu_id]
      next unless taxon_name_id

      taxon_id = taxon_name_id_to_taxon_id[taxon_name_id]
      next unless taxon_id

      row = [
        taxon_id,
        locality,
        dwc_occ.occurrenceStatus,
        dwc_occ.associatedReferences
      ]

      tbl << row
    end

    ::Export::Dwca.output_csv(tbl)
  end

end
