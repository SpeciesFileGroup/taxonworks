# CSV for Types and Specimen extension (for checklist archives)
# See http://rs.gbif.org/extension/gbif/1.0/typesandspecimen.xml
#
# Note: Using only DwcOccurrence data from CollectionObject records.
# Only includes fields that can be populated from DwcOccurrence.
# Type-specific fields like typeDesignationType and typeDesignatedBy would
# require accessing TypeMaterial objects directly.
#
module Export::CSV::Dwc::Extension::TypesAndSpecimen

  # Alias for brevity
  GBIF = Export::Dwca::GbifProfile::TypeSpecimen

  # Fields used in checklist exports (subset of full GBIF profile)
  # Only including fields that can be populated from DwcOccurrence data
  # from CollectionObject records with type materials.
  # Note: :id is used instead of TAXON_ID for DwC-A star joins
  CHECKLIST_FIELDS = [
    :id,                      # Required for DwC-A star joins (maps to taxonID)
    GBIF::TYPE_STATUS,
    GBIF::SCIENTIFIC_NAME,
    GBIF::TAXON_RANK,
    GBIF::OCCURRENCE_ID,
    GBIF::INSTITUTION_CODE,
    GBIF::COLLECTION_CODE,
    GBIF::CATALOG_NUMBER,
    GBIF::LOCALITY,
    GBIF::SEX,
    GBIF::RECORDED_BY,
    GBIF::VERBATIM_EVENT_DATE
  ].freeze

  HEADERS = CHECKLIST_FIELDS

  HEADERS_NAMESPACES = CHECKLIST_FIELDS.map do |field|
    field == :id ? '' : GBIF::NAMESPACES[field]
  end.freeze

  # Generate CSV for types and specimen extension using only DwcOccurrence data
  # @param scope [ActiveRecord::Relation] DwcOccurrence records
  # @param taxon_name_to_id [Hash] mapping of "rank:scientificName" => taxonID
  # @return [String] CSV content
  def self.csv(scope, taxon_name_to_id)
    tbl = []
    tbl[0] = HEADERS

    # Only process CollectionObject records with typeStatus populated
    # Filter at SQL level for performance
    scope
      .where(dwc_occurrence_object_type: 'CollectionObject')
      .where.not(typeStatus: [nil, ''])
      .find_each do |dwc_occ|
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

      # Get typeStatus field (already filtered to non-blank)
      type_status_str = dwc_occ.typeStatus

      # Split by delimiter to get individual type designations
      type_statuses = type_status_str.split(Export::Dwca::DELIMITER).map(&:strip).reject(&:blank?)

      # Create one row per type designation
      type_statuses.each do |type_status|
        row = [
          taxon_id,                     # id (for star join to core taxon)
          type_status,                  # typeStatus
          dwc_occ.scientificName,       # scientificName
          dwc_occ.taxonRank,            # taxonRank
          dwc_occ.occurrenceID,         # occurrenceID
          dwc_occ.institutionCode,      # institutionCode
          dwc_occ.collectionCode,       # collectionCode
          dwc_occ.catalogNumber,        # catalogNumber
          dwc_occ.locality,             # locality
          dwc_occ.sex,                  # sex
          dwc_occ.recordedBy,           # recordedBy
          dwc_occ.verbatimEventDate     # verbatimEventDate
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
