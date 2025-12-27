module DwcOccurrence::ColumnSets
  # Lists are arrays of DwcOccurrence column names only.

  # The column named :id is *not* excluded, it's required for star-joining - but
  # we get to choose to populate with UUIDs instead of db ids.
  EXCLUDED_OCCURRENCE_COLUMNS =
    (::DwcOccurrence.columns.collect{|c| c.name.to_sym} -
      (
        ::DwcOccurrence.target_occurrence_columns -
          [:dwc_occurrence_object_id, :dwc_occurrence_object_type]
      )
    ).freeze

  # Keys are dwc_occurrence columns, values are DwC Taxon Extension columns:
  # https://rs.gbif.org/core/dwc_taxon_2024-02-19.xml
  # Excludes ...ID fields (except taxonID which will be copied from occurrenceID)
  # Excludes purl.org/dc/* fields (Record-level group)
  # Note: taxonID is excluded here because it will be created via copy_column from occurrenceID
  CHECKLIST_TAXON_EXTENSION_COLUMNS = {
    scientificName: :scientificName,
    acceptedNameUsage: :acceptedNameUsage,
    parentNameUsage: :parentNameUsage,
    originalNameUsage: :originalNameUsage,
    nameAccordingTo: :nameAccordingTo,
    namePublishedIn: :namePublishedIn,
    namePublishedInYear: :namePublishedInYear,
    higherClassification: :higherClassification,
    kingdom: :kingdom,
    phylum: :phylum,
    dwcClass: :class,  # Note: column is dwcClass, DwC Taxon field is 'class'
    order: :order,
    superfamily: :superfamily,
    family: :family,
    subfamily: :subfamily,
    tribe: :tribe,
    subtribe: :subtribe,
    genus: :genus,
    subgenus: :subgenus,
    specificEpithet: :specificEpithet,
    infraspecificEpithet: :infraspecificEpithet,
    taxonRank: :taxonRank,
    verbatimTaxonRank: :verbatimTaxonRank,
    scientificNameAuthorship: :scientificNameAuthorship,
    vernacularName: :vernacularName,
    nomenclaturalCode: :nomenclaturalCode,
    taxonomicStatus: :taxonomicStatus,
    nomenclaturalStatus: :nomenclaturalStatus,
    taxonRemarks: :taxonRemarks
  }.freeze

  # For checklist exports, taxonID and parentNameUsageID are computed during normalization
  # :id is excluded since we build taxonID from scratch
  EXCLUDED_CHECKLIST_COLUMNS =
    (::DwcOccurrence.columns.collect{|c| c.name.to_sym} -
      (
        CHECKLIST_TAXON_EXTENSION_COLUMNS.keys -
          [:dwc_occurrence_object_id, :dwc_occurrence_object_type]
      )
    ).freeze

end