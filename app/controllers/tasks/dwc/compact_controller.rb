class Tasks::Dwc::CompactController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  # POST /tasks/dwc/compact/compact.json
  def compact
    q = ::Queries::DwcOccurrence::Filter.new(params)

    scope = q.all
      .where(project_id: sessions_current_project_id)
      .select(::DwcOccurrence.target_columns)

    tempfile = ::Export::CSV.copy_table(scope)
    tsv_string = tempfile.read
    tempfile.close!

    table = Utilities::DarwinCore::Table.new(tsv_string:)
    preview = params[:preview] == 'true' || params[:preview] == true
    table.compact(by: :catalog_number, preview:)

    render json: {
      headers: ordered_headers(table.headers),
      rows: table.rows,
      errors: table.errors,
      meta: {
        total_rows: table.rows.size,
        preview:
      }
    }
  end

  private

  def ordered_headers(headers)
    ordered = DWC_COMPACT_COLUMN_ORDER.select { |h| headers.include?(h) }
    remaining = headers - ordered
    ordered + remaining
  end

  # Display order for compacted DwC columns.
  # Derived columns are appended after individualCount.
  # Housekeeping/TW-internal columns are excluded.
  DWC_COMPACT_COLUMN_ORDER = %w[
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
end
