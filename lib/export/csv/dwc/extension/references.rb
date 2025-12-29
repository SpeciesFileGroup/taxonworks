# CSV for References/Literature extension (for checklist archives)
# See http://rs.gbif.org/extension/gbif/1.0/references.xml
#
# Note: Using only DwcOccurrence data, we can only populate bibliographicCitation.
# Other fields (title, author, date, identifier, etc.) would require accessing
# the source objects directly.
#
module Export::CSV::Dwc::Extension::References

  # Alias for brevity
  GBIF = Export::Dwca::GbifProfile::Reference

  # Fields used in checklist exports (subset of full GBIF profile)
  # !! Only including fields that can be populated from DwcOccurrence data,
  # which only includes Asserted Distribution data on references.
  # Note: :id is used instead of TAXON_ID for DwC-A star joins
  CHECKLIST_FIELDS = [
    :id,                         # Required for DwC-A star joins (maps to taxonID)
    GBIF::BIBLIOGRAPHIC_CITATION
  ].freeze

  HEADERS = CHECKLIST_FIELDS

  HEADERS_NAMESPACES = CHECKLIST_FIELDS.map do |field|
    field == :id ? '' : GBIF::NAMESPACES[field]
  end.freeze

  # Generate CSV for references extension using only DwcOccurrence data
  # @param scope [ActiveRecord::Relation] DwcOccurrence records
  # @param taxon_name_to_id [Hash] mapping of "rank:scientificName" => taxonID
  # @return [String] CSV content
  def self.csv(scope, taxon_name_to_id)
    tbl = []
    tbl[0] = HEADERS

    scope.find_each do |dwc_occ|
      # Look up the taxonID for this occurrence's scientificName and rank
      rank = dwc_occ.taxonRank&.downcase
      sci_name = dwc_occ.scientificName
      taxon_id = nil
      if rank.present? && sci_name.present?
        key = "#{rank}:#{sci_name}"
        taxon_id = taxon_name_to_id[key]
      end

      # Skip if we can't find the taxonID (shouldn't happen if data is consistent)
      next unless taxon_id

      # Get associatedReferences field (only populated for AssertedDistribution)
      references_str = dwc_occ.associatedReferences
      next if references_str.blank?

      # Split by delimiter to get individual citations
      citations = references_str.split(Export::Dwca::DELIMITER).map(&:strip).reject(&:blank?)

      # Create one row per citation
      citations.each do |citation|
        row = [
          taxon_id,           # id (for star join to core taxon)
          citation            # bibliographicCitation - the formatted citation
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
