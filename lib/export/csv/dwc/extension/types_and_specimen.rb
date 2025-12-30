# CSV for Types and Specimen extension (for checklist archives).
# See http://rs.gbif.org/extension/gbif/1.0/typesandspecimen.xml
#
# Note: Using only DwcOccurrence data from CollectionObject records.
# Only includes fields that can be populated from DwcOccurrence.
# Type-specific fields like typeDesignationType and typeDesignatedBy would
# require accessing TypeMaterial objects directly.
module Export::CSV::Dwc::Extension::TypesAndSpecimen

  GBIF = Export::Dwca::GbifProfile::TypeSpecimen

  # Fields used in checklist exports (subset of full GBIF profile).
  # Only including fields that can be populated from DwcOccurrence data
  # from CollectionObject records with type materials.
  CHECKLIST_FIELDS = [
    :id, # Required for DwC-A star joins (maps to taxonID)
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

  # Generate CSV for types and specimen extension using only DwcOccurrence data.
  # @param scope [ActiveRecord::Relation] DwcOccurrence records
  # @param taxon_name_id_to_taxon_id [Hash] mapping of taxon_name_id => taxonID
  # @return [String] CSV content
  def self.csv(scope, taxon_name_id_to_taxon_id)
    tbl = []
    tbl[0] = HEADERS

    # Build occurrence_to_otu mapping for CollectionObjects.
    co_mapping = scope
      .where(dwc_occurrence_object_type: 'CollectionObject')
      .where.not(typeStatus: [nil, ''])
      .joins('JOIN collection_objects co ON co.id = dwc_occurrences.dwc_occurrence_object_id')
      .joins('JOIN taxon_determinations td ON td.taxon_determination_object_id = co.id AND td.taxon_determination_object_type = \'CollectionObject\' AND td.position = 1')
      .pluck('dwc_occurrences.dwc_occurrence_object_id', 'td.otu_id')
      .to_h

    otu_ids = co_mapping.values.compact.uniq
    otu_to_taxon_name_id = ::Otu
      .where(id: otu_ids)
      .joins(:taxon_name)
      .pluck(Arel.sql('otus.id'), Arel.sql('COALESCE(taxon_names.cached_valid_taxon_name_id, taxon_names.id)'))
      .to_h

    scope
      .where(dwc_occurrence_object_type: 'CollectionObject')
      .where.not(typeStatus: [nil, ''])
      .find_each do |dwc_occ|
      otu_id = co_mapping[dwc_occ.dwc_occurrence_object_id]
      next unless otu_id

      taxon_name_id = otu_to_taxon_name_id[otu_id]
      next unless taxon_name_id

      taxon_id = taxon_name_id_to_taxon_id[taxon_name_id]
      next unless taxon_id

      type_status_str = dwc_occ.typeStatus

      type_statuses = type_status_str.split(Export::Dwca::DELIMITER).map(&:strip).reject(&:blank?)

      type_statuses.each do |type_status|
        row = [
          taxon_id,
          type_status,
          dwc_occ.scientificName,
          dwc_occ.taxonRank,
          dwc_occ.occurrenceID,
          dwc_occ.institutionCode,
          dwc_occ.collectionCode,
          dwc_occ.catalogNumber,
          dwc_occ.locality,
          dwc_occ.sex,
          dwc_occ.recordedBy,
          dwc_occ.verbatimEventDate
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
