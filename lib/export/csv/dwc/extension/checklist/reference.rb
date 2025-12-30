# CSV for References/Literature extension (for checklist archives)
# See http://rs.gbif.org/extension/gbif/1.0/references.xml
#
# Note: Using only DwcOccurrence data, we can only populate bibliographicCitation.
# Other fields (title, author, date, identifier, etc.) would require accessing
# the source objects directly.
#
module Export::CSV::Dwc::Extension::Checklist::Reference

  # Alias for brevity
  GBIF = Export::Dwca::GbifProfile::Reference

  # Fields used in checklist exports (subset of full GBIF profile).
  # !! Only including fields that can be populated from DwcOccurrence data,
  # which only includes Asserted Distribution data on references.
  CHECKLIST_FIELDS = [
    :id, # Required for DwC-A star joins (maps to taxonID)
    GBIF::BIBLIOGRAPHIC_CITATION
  ].freeze

  HEADERS = CHECKLIST_FIELDS

  HEADERS_NAMESPACES = CHECKLIST_FIELDS.map do |field|
    field == :id ? '' : GBIF::NAMESPACES[field]
  end.freeze

  # Generate CSV for references extension using only DwcOccurrence data.
  # @param scope [ActiveRecord::Relation] DwcOccurrence records
  # @param taxon_name_id_to_taxon_id [Hash] mapping of taxon_name_id => taxonID
  # @return [String] CSV content
  def self.csv(scope, taxon_name_id_to_taxon_id)
    tbl = []
    tbl[0] = HEADERS

    # Build occurrence_to_otu and otu_to_taxon_name_id mappings (similar to
    # distribution extension) for AssertedDistributions.
    ad_mapping = scope
      .where(dwc_occurrence_object_type: 'AssertedDistribution')
      .where.not(associatedReferences: [nil, ''])
      .joins("JOIN asserted_distributions ad ON ad.id = dwc_occurrences.dwc_occurrence_object_id AND ad.asserted_distribution_object_type = 'Otu'")
      .pluck('dwc_occurrences.dwc_occurrence_object_id', 'ad.asserted_distribution_object_id')
      .to_h

    otu_ids = ad_mapping.values.compact.uniq
    otu_to_taxon_name_id = ::Otu.where(id: otu_ids)
      .joins(:taxon_name)
      .pluck(Arel.sql('otus.id'), Arel.sql('COALESCE(taxon_names.cached_valid_taxon_name_id, taxon_names.id)'))
      .to_h

    # Only process AssertedDistribution records with associatedReferences
    # populated.
    scope
      .where(dwc_occurrence_object_type: 'AssertedDistribution')
      .where.not(associatedReferences: [nil, ''])
      .find_each do |dwc_occ|
      # Look up taxon_name_id via OTU.
      otu_id = ad_mapping[dwc_occ.dwc_occurrence_object_id]
      next unless otu_id

      taxon_name_id = otu_to_taxon_name_id[otu_id]
      next unless taxon_name_id

      # Look up taxonID from taxon_name_id.
      taxon_id = taxon_name_id_to_taxon_id[taxon_name_id]
      next unless taxon_id

      references_str = dwc_occ.associatedReferences

      citations = references_str.split(Export::Dwca::DELIMITER).map(&:strip).reject(&:blank?)

      citations.each do |citation|
        row = [
          taxon_id,
          citation
        ]

        tbl << row
      end
    end

    output = StringIO.new
    tbl.each do |row|
      output.puts ::CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end

    output.string
  end

end
