# CSV for Types and Specimen extension (for checklist archives)
# See http://rs.gbif.org/extension/gbif/1.0/typesandspecimen.xml
#
# Note: Using only DwcOccurrence data from CollectionObject records.
# Only includes fields that can be populated from DwcOccurrence.
# Type-specific fields like typeDesignationType and typeDesignatedBy would
# require accessing TypeMaterial objects directly.
#
module Export::CSV::Dwc::Extension::TypesAndSpecimen

  # Maintain this for order.
  # Only including fields that can be populated from DwcOccurrence data
  # from CollectionObject records with type materials.
  HEADERS_HASH = {
    # Required by dwca to link to core file (taxonID), not part of the extension.
    id: '',
    typeStatus: 'http://rs.tdwg.org/dwc/terms/typeStatus',
    scientificName: 'http://rs.tdwg.org/dwc/terms/scientificName',
    taxonRank: 'http://rs.tdwg.org/dwc/terms/taxonRank',
    occurrenceID: 'http://rs.tdwg.org/dwc/terms/occurrenceID',
    institutionCode: 'http://rs.tdwg.org/dwc/terms/institutionCode',
    collectionCode: 'http://rs.tdwg.org/dwc/terms/collectionCode',
    catalogNumber: 'http://rs.tdwg.org/dwc/terms/catalogNumber',
    locality: 'http://rs.tdwg.org/dwc/terms/locality',
    sex: 'http://rs.tdwg.org/dwc/terms/sex',
    recordedBy: 'http://rs.tdwg.org/dwc/terms/recordedBy',
    verbatimEventDate: 'http://rs.tdwg.org/dwc/terms/verbatimEventDate'
  }.freeze

  HEADERS = HEADERS_HASH.keys.freeze

  HEADERS_NAMESPACES = HEADERS_HASH.values.freeze

  # Generate CSV for types and specimen extension using only DwcOccurrence data
  # @param scope [ActiveRecord::Relation] DwcOccurrence records
  # @param taxon_name_to_id [Hash] mapping of "rank:scientificName" => taxonID
  # @return [String] CSV content
  def self.csv(scope, taxon_name_to_id)
    tbl = []
    tbl[0] = HEADERS

    # Only process CollectionObject records (not FieldOccurrence)
    scope.where(dwc_occurrence_object_type: 'CollectionObject').find_each do |dwc_occ|
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

      # Get typeStatus field (only populated for type specimens)
      type_status_str = dwc_occ.typeStatus
      next if type_status_str.blank?

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
