# Darwin Core Archive (DWC-A) shared constants and utilities
module Export::Dwca

  # !! If changes are made to this or related Dwc files you should update the INDEX_VERSION constant.
  #
  # Version is a way to track dates where the indexing changed significantly
  # such that all or most of the index should be regenerated.
  # To add a version use `Time.now` via IRB.
  INDEX_VERSION = [
    '2021-10-12 17:00:00.000000 -0500',    # First major refactor
    '2021-10-15 17:00:00.000000 -0500',    # Minor  Excludes footprintWKT, and references to GeographicArea in gazetteer; new form of media links
    '2021-11-04 17:00:00.000000 -0500',    # Minor  Removes '|', fixes some mappings
    '2021-11-08 13:00:00.000000 -0500',    # PENDING: Minor  Adds depth mappings
    '2021-11-30 13:00:00.000000 -0500',    # Fix inverted long,lat
    '2022-01-21 16:30:00.000000 -0500',    # basisOfRecord can now be FossilSpecimen; occurrenceId exporting; adds redundant time fields
    '2022-03-31 16:30:00.000000 -0500',    # collectionCode, occurrenceRemarks and various small fixes
    '2022-04-28 16:30:00.000000 -0500',    # add dwcOccurrenceStatus
    '2022-09-28 16:30:00.000000 -0500',    # add phylum, class, order, higherClassification
    '2023-04-03 16:30:00.000000 -0500',    # add associatedTaxa; updating InternalAttributes is now reflected in index
    '2023-12-14 16:30:00.000000 -0500',    # add verbatimLabel
    '2023-12-21 11:00:00.000000 -0500',    # add caste (via biocuration), identificationRemarks
    '2024-09-13 11:00:00.000000 -0500',    # enable collectionCode, object and collecting event related IDs
    '2026-03-21 12:00:00.000000 -0500'     # add otu_id to dwc_occurrences
  ].freeze

  # Delimiter used for concatenating multiple values in DwC fields
  # Used when multiple items (e.g., references, media, identifiers) need to be
  # represented in a single Darwin Core field.
  DELIMITER = ' | '.freeze

  # @param tbl [Array<Array>] table data
  # @return [String] TSV content
  def self.output_csv(tbl)
    output = StringIO.new
    tbl.each do |row|
      output.puts ::CSV.generate_line(row, col_sep: "\t", encoding: Encoding::UTF_8)
    end
    output.string
  end

  # Create a DwC-A occurrence download asynchronously
  # @param core_scope [ActiveRecord::Relation] Scope of DwcOccurrence records
  # @param request_url [String] URL of the request
  # @param predicate_extensions [Hash] Predicate extensions to include
  # @param taxonworks_extensions [Array] TaxonWorks extensions to include
  # @param extension_scopes [Hash] Additional extension scopes
  # @param project_id [Integer] Project ID
  # @return [Download::DwcArchive] The download record
  def self.download_async(core_scope, request_url, predicate_extensions: {}, taxonworks_extensions: [], extension_scopes: {}, project_id: nil)
    name = "dwc_occurrences_#{DateTime.now}.zip"

    download = ::Download::DwcArchive.create!(
      name: "DwC Archive for occurrences on #{Time.now}.",
      description: 'A zip file containing a Darwin Core Archive of occurrence records.',
      filename: name,
      request: request_url,
      expires: 2.days.from_now
    )

    DwcaCreateDownloadJob.perform_later(
      download.id,
      core_scope: core_scope.to_sql,
      extension_scopes:,
      predicate_extensions:,
      taxonworks_extensions:,
      project_id:
    )

    download
  end

  DEFAULT_CHECKLIST_DESCRIPTION = 'A zip file containing a Darwin Core Archive checklist.'.freeze

  # Create a DwC-A checklist download asynchronously
  # @param core_otu_scope_params [Hash] OTU query parameters
  # @param request_url [String] URL of the request
  # @param extensions [Array<Symbol>] Extensions to include (e.g., [:distribution, :references])
  # @param accepted_name_mode [String] How to handle unaccepted names ('replace_with_accepted_name' or 'accepted_name_usage_id')
  # @param description_topics [Array<Integer>] Ordered list of topic IDs for description extension
  # @param download_name [String, nil] Optional custom name for the Download record
  # @param download_description [String, nil] Optional custom description for the Download record
  # @param project_id [Integer] Project ID
  # @return [Download::DwcArchive::Checklist] The download record
  def self.checklist_download_async(core_otu_scope_params, request_url, extensions: [], accepted_name_mode: Checklist::Data::REPLACE_WITH_ACCEPTED_NAME, description_topics: [], download_name: nil, download_description: nil, project_id: nil)
    filename = "dwc_checklist_#{DateTime.now}.zip"
    display_name = download_name.presence || "DwC Checklist on #{Time.now}."
    description = download_description.presence || DEFAULT_CHECKLIST_DESCRIPTION

    download = ::Download::DwcArchive::Checklist.create!(
      name: display_name,
      description: description,
      filename: filename,
      request: request_url,
      expires: 2.days.from_now
    )

    DwcaCreateChecklistDownloadJob.perform_later(
      download.id,
      core_otu_scope_params:,
      extensions:,
      accepted_name_mode:,
      description_topics:,
      project_id:
    )

    download
  end

end
