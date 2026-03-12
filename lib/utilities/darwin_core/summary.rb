# Summary helpers for compacted DarwinCore tables.
# Methods here operate on plain row Hashes and have no
# TaxonWorks or Rails dependencies.
#
# @author Claude (>50% of code)
#
module Utilities::DarwinCore::Summary

  # Display order for compacted DwC columns.
  # Derived columns appear after individualCount.
  COLUMN_ORDER = %w[
    catalogNumber
    otherCatalogNumbers
    scientificName
    scientificNameAuthorship
    individualCount
    adultMale
    adultFemale
    immatureNymph
    exuvia
    sex
    lifeStage
    caste
    eventDate
    eventTime
    year
    month
    day
    startDayOfYear
    endDayOfYear
    country
    stateProvince
    county
    verbatimLocality
    waterBody
    habitat
    decimalLatitude
    decimalLongitude
    verbatimCoordinates
    verbatimLatitude
    verbatimLongitude
    coordinateUncertaintyInMeters
    geodeticDatum
    footprintWKT
    verbatimElevation
    minimumElevationInMeters
    maximumElevationInMeters
    verbatimDepth
    minimumDepthInMeters
    maximumDepthInMeters
    basisOfRecord
    occurrenceID
    occurrenceStatus
    recordNumber
    fieldNumber
    eventID
    samplingProtocol
    preparations
    typeStatus
    identifiedBy
    identifiedByID
    dateIdentified
    recordedBy
    recordedByID
    kingdom
    phylum
    dwcClass
    order
    higherClassification
    superfamily
    family
    subfamily
    tribe
    subtribe
    genus
    specificEpithet
    infraspecificEpithet
    taxonRank
    nomenclaturalCode
    previousIdentifications
    institutionCode
    institutionID
    georeferenceProtocol
    georeferenceRemarks
    georeferenceSources
    georeferencedBy
    georeferencedDate
    verbatimSRS
    verbatimEventDate
    associatedMedia
    associatedTaxa
    occurrenceRemarks
    verbatimLabel
  ].freeze

  # Return headers sorted by COLUMN_ORDER, with any unrecognised
  # columns appended at the end.
  #
  # @param headers [Array<String>]
  # @return [Array<String>]
  def self.ordered_headers(headers)
    ordered = COLUMN_ORDER.select { |h| headers.include?(h) }
    remaining = headers - ordered
    ordered + remaining
  end

  # Count rows (with a catalogNumber) that shared their catalogNumber
  # with at least one other row — i.e. rows that were involved in a merge.
  # Rows without a catalogNumber are excluded from this count.
  #
  # @param rows [Array<Hash>]
  # @return [Integer]
  def self.count_rows_compacted(rows)
    with_catalog_number = rows.select { |r| r['catalogNumber'].to_s.strip.length > 0 }
    grouped = with_catalog_number.group_by { |r| r['catalogNumber'] }
    grouped.sum { |_key, group| group.size > 1 ? group.size : 0 }
  end

  # Return true if the year portion of event_date is before 1700.
  # Handles ISO 8601 ranges (slash-separated) by inspecting the start date.
  #
  # @param event_date [String, nil]
  # @return [Boolean]
  def self.year_before_1700?(event_date)
    return false if event_date.nil? || event_date.empty?
    date_part = event_date.include?('/') ? event_date.split('/').first : event_date
    match = date_part.match(/\A(\d{4})/)
    match && match[1].to_i < 1700
  end

end
