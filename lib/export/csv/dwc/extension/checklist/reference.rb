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
    :id, # Required for DwC-A star joins (taxonID, an OTU UUID)
    :bibliographicCitation
  ].freeze

  HEADERS = CHECKLIST_FIELDS

  HEADERS_NAMESPACES = CHECKLIST_FIELDS.map do |field|
    field == :id ? '' : GBIF::NAMESPACES[field]
  end.freeze

  # Generate CSV for references extension using only DwcOccurrence data.
  # @param scope [ActiveRecord::Relation] DwcOccurrence records
  # @param taxon_name_id_to_taxon_id [Hash] taxon_name_id => OTU UUID (used as dwc:taxonID in the checklist core)
  # @param accepted_name_mode [String] checklist synonym handling mode
  # @return [String] CSV content
  def self.csv(scope, taxon_name_id_to_taxon_id, accepted_name_mode:)
    tbl = []
    tbl[0] = HEADERS
    seen_rows = {}

    ad_scope = scope
      .where(dwc_occurrence_object_type: 'AssertedDistribution')
      .where.not(associatedReferences: [nil, ''])

    otu_to_taxon_name_id = ad_scope
      .joins('JOIN otus ON otus.id = dwc_occurrences.otu_id')
      .joins('JOIN taxon_names ON taxon_names.id = otus.taxon_name_id')
      .pluck(
        Arel.sql('dwc_occurrences.otu_id'),
        Arel.sql(
          if accepted_name_mode == ::Export::Dwca::Checklist::Data::ACCEPTED_NAME_USAGE_ID
            'taxon_names.id'
          else
            'COALESCE(taxon_names.cached_valid_taxon_name_id, taxon_names.id)'
          end
        )
      )
      .to_h

    ad_scope.find_each do |dwc_occ|
      taxon_name_id = otu_to_taxon_name_id[dwc_occ.otu_id]
      next unless taxon_name_id

      taxon_id = taxon_name_id_to_taxon_id[taxon_name_id]
      next unless taxon_id

      references_str = dwc_occ.associatedReferences

      citations = references_str.split(Export::Dwca::DELIMITER).map(&:strip).reject(&:blank?)

      citations.each do |citation|
        row_key = [taxon_id, citation]
        next if seen_rows[row_key]

        row = [
          taxon_id,
          citation
        ]

        tbl << row
        seen_rows[row_key] = true
      end
    end

    ::Export::Dwca.output_csv(tbl)
  end

end
