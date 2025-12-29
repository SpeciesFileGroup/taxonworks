# CSV for Species Distribution extension (for checklist archives)
# See http://rs.gbif.org/extension/gbif/1.0/distribution.xml
#
module Export::CSV::Dwc::Extension::SpeciesDistribution

  # Alias for brevity
  GBIF = Export::Dwca::GbifProfile::SpeciesDistribution

  # Fields used in checklist exports (subset of full GBIF profile)
  # Note: :id is used instead of TAXON_ID for DwC-A star joins
  CHECKLIST_FIELDS = [
    :id,                    # Required for DwC-A star joins (maps to taxonID)
    GBIF::LOCALITY,
    GBIF::OCCURRENCE_STATUS,
    GBIF::SOURCE
  ].freeze

  HEADERS = CHECKLIST_FIELDS

  HEADERS_NAMESPACES = CHECKLIST_FIELDS.map do |field|
    field == :id ? '' : GBIF::NAMESPACES[field]
  end.freeze

  # Generate CSV for species distribution extension
  # @param scope [ActiveRecord::Relation] DwcOccurrence records from AssertedDistribution
  # @param taxon_name_to_id [Hash] mapping of "rank:scientificName" => taxonID
  # @return [String] CSV content
  def self.csv(scope, taxon_name_to_id)
    tbl = []
    tbl[0] = HEADERS

    scope.find_each do |dwc_occ|
      # Build locality from geographic components
      locality_parts = [
        dwc_occ.country,
        dwc_occ.stateProvince,
        dwc_occ.county
      ].compact.reject(&:empty?)
      locality = locality_parts.join(', ').presence

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

      row = [
        taxon_id,                          # id (for star join to core taxon)
        locality,                          # locality
        dwc_occ.occurrenceStatus,          # occurrenceStatus
        dwc_occ.associatedReferences       # source
      ]

      tbl << row
    end

    output = StringIO.new
    tbl.each do |row|
      output.puts ::CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end

    output.string
  end

end
