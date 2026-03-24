# CSV for Types and Specimen extension (for checklist archives).
# See http://rs.gbif.org/extension/gbif/1.0/typesandspecimen.xml
#
# Note: Currently only includes fields that can be populated from DwcOccurrence.
# Type-specific fields like typeDesignationType and typeDesignatedBy would
# require accessing TypeMaterial objects directly.
module Export::CSV::Dwc::Extension::Checklist::TypesAndSpecimen

  GBIF = Export::Dwca::GbifProfile::TypeSpecimen

  # Fields used in checklist exports (subset of full GBIF profile).
  # Only including fields that can be populated from DwcOccurrence data
  # from CollectionObject records with type materials.
  CHECKLIST_FIELDS = [
    :id, # Required for DwC-A star joins (taxonID, an OTU UUID)
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
  # @param taxon_name_id_to_taxon_id [Hash] taxon_name_id => OTU UUID (used as dwc:taxonID in the checklist core)
  # @return [String] CSV content
  def self.csv(scope, taxon_name_id_to_taxon_id)
    tbl = []
    tbl[0] = HEADERS

    co_scope = scope
      .where(dwc_occurrence_object_type: 'CollectionObject')
      .where.not(typeStatus: [nil, ''])

    otu_to_taxon_name_id = co_scope
      .joins('JOIN otus ON otus.id = dwc_occurrences.otu_id')
      .joins('JOIN taxon_names ON taxon_names.id = otus.taxon_name_id')
      .pluck(
        Arel.sql('dwc_occurrences.otu_id'),
        Arel.sql('COALESCE(taxon_names.cached_valid_taxon_name_id, taxon_names.id)')
      )
      .to_h

    co_scope.find_each do |dwc_occ|
      taxon_name_id = otu_to_taxon_name_id[dwc_occ.otu_id]
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

    ::Export::Dwca.output_csv(tbl)
  end

end
