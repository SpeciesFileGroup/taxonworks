# CSV for Vernacular Name extension (for checklist archives)
# See http://rs.gbif.org/extension/gbif/1.0/vernacularname.xml
#
# Note: NOT using DwcOccurrence data (vernacularName field is not populated).
# Accesses CommonName records directly via OTU relationships.
#
module Export::CSV::Dwc::Extension::VernacularName

  # Alias for brevity
  GBIF = Export::Dwca::GbifProfile::VernacularName

  # Fields used in checklist exports (subset of full GBIF profile)
  # Only including fields that can be populated from CommonName data.
  # Note: :id is used instead of TAXON_ID for DwC-A star joins
  CHECKLIST_FIELDS = [
    :id,                     # Required for DwC-A star joins (maps to taxonID)
    GBIF::VERNACULAR_NAME,
    GBIF::LANGUAGE,
    GBIF::TEMPORAL
  ].freeze

  HEADERS = CHECKLIST_FIELDS

  HEADERS_NAMESPACES = CHECKLIST_FIELDS.map do |field|
    field == :id ? '' : GBIF::NAMESPACES[field]
  end.freeze

  # Generate CSV for vernacular name extension from CommonName records
  # @param core_otu_scope [Hash] OTU query params from ChecklistData
  # @param taxon_name_to_id [Hash] mapping of "rank:scientificName" => taxonID
  # @return [String] CSV content
  def self.csv(core_otu_scope, taxon_name_to_id)
    tbl = []
    tbl[0] = HEADERS

    # Get OTUs from scope using the Filter to support all query parameters
    otus = ::Queries::Otu::Filter.new(core_otu_scope).all

    # Get common names for these OTUs
    common_names = CommonName
      .where(otu_id: otus.select(:id))
      .includes(:language, otu: :taxon_name)

    common_names.find_each do |cn|
      # Get the taxon name for this OTU to look up taxonID
      taxon_name = cn.otu&.taxon_name
      next unless taxon_name

      # Build the key for taxon_name_to_id lookup
      rank = taxon_name.rank&.downcase
      sci_name = taxon_name.cached
      next unless rank.present? && sci_name.present?

      key = "#{rank}:#{sci_name}"
      taxon_id = taxon_name_to_id[key]
      next unless taxon_id

      # Build temporal string from start_year and end_year
      temporal = nil
      if cn.start_year.present? && cn.end_year.present?
        temporal = "#{cn.start_year}-#{cn.end_year}"
      elsif cn.start_year.present?
        temporal = cn.start_year.to_s
      elsif cn.end_year.present?
        temporal = cn.end_year.to_s
      end

      row = [
        taxon_id,                    # id (for star join to core taxon)
        cn.name,                     # vernacularName (required)
        cn.language&.alpha_2,        # language (ISO 639-1 code)
        temporal                     # temporal
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
