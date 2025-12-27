# CSV for Species Distribution extension (for checklist archives)
# See http://rs.gbif.org/extension/gbif/1.0/distribution.xml
#
module Export::CSV::Dwc::Extension::SpeciesDistribution

  # Maintain this for order.
  HEADERS_HASH = {
    # Required by dwca to link to core file (taxonID), not part of the extension.
    id: '',
    locality: 'http://rs.tdwg.org/dwc/terms/locality',
    countryCode: 'http://rs.tdwg.org/dwc/terms/countryCode',
    occurrenceStatus: 'http://rs.tdwg.org/dwc/terms/occurrenceStatus',
    source: 'http://purl.org/dc/terms/source'
  }.freeze

  HEADERS = HEADERS_HASH.keys.freeze

  HEADERS_NAMESPACES = HEADERS_HASH.values.freeze

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
        dwc_occ.countryCode,               # countryCode
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
