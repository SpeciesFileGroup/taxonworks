# CSV for Species Distribution extension (for checklist archives)
# See http://rs.gbif.org/extension/gbif/1.0/distribution.xml
#
module Export::CSV::Dwc::Extension::SpeciesDistribution

  GBIF = Export::Dwca::GbifProfile::SpeciesDistribution

  # Fields used in checklist exports (subset of full GBIF profile).
  CHECKLIST_FIELDS = [
    :id, # Required for DwC-A star joins (maps to taxonID)
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
  # @param taxon_name_id_to_taxon_id [Hash] mapping of taxon_name_id => taxonID
  # @return [String] CSV content
  def self.csv(scope, taxon_name_id_to_taxon_id)
    tbl = []
    tbl[0] = HEADERS

    # Build occurrence_to_otu mapping for lookups.
    occurrence_to_otu = scope
      .where(dwc_occurrence_object_type: 'AssertedDistribution')
      .joins("JOIN asserted_distributions ad ON ad.id = dwc_occurrences.dwc_occurrence_object_id AND ad.asserted_distribution_object_type = 'Otu'")
      .pluck('dwc_occurrences.dwc_occurrence_object_id', 'ad.asserted_distribution_object_id')
      .to_h

    # Get OTU to taxon_name_id mapping.
    otu_ids = occurrence_to_otu.values.compact.uniq
    otu_to_taxon_name_id = ::Otu
      .where(id: otu_ids)
      .joins(:taxon_name)
      .pluck(
        Arel.sql('otus.id'),
        Arel.sql('COALESCE(taxon_names.cached_valid_taxon_name_id, taxon_names.id)')
      )
      .to_h

    scope.find_each do |dwc_occ|
      locality_parts = [
        dwc_occ.country,
        dwc_occ.stateProvince,
        dwc_occ.county
      ].compact.reject(&:empty?)
      locality = locality_parts.join(', ').presence

      # Look up taxon_name_id via OTU
      # TODO: this doesn't look right
      otu_id = occurrence_to_otu[dwc_occ.dwc_occurrence_object_id]
      next unless otu_id

      taxon_name_id = otu_to_taxon_name_id[otu_id]
      next unless taxon_name_id

      # Look up taxonID from taxon_name_id
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

    output = StringIO.new
    # TODO: this can't be generated from an array of lines all at once?
    tbl.each do |row|
      output.puts ::CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end

    output.string
  end

end
