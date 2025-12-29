# Darwin Core Archive (DWC-A) shared constants and utilities
module Export::Dwca

  # Delimiter used for concatenating multiple values in DwC fields
  # Used when multiple items (e.g., references, media, identifiers) need to be
  # represented in a single Darwin Core field.
  DELIMITER = ' | '.freeze

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

  # Create a DwC-A checklist download asynchronously
  # @param core_otu_scope_params [Hash] OTU query parameters
  # @param request_url [String] URL of the request
  # @param extensions [Array<Symbol>] Extensions to include (e.g., [:distribution, :references])
  # @param accepted_name_mode [String] How to handle unaccepted names ('replace_with_accepted_name' or 'accepted_name_usage_id')
  # @param project_id [Integer] Project ID
  # @return [Download::DwcArchive::Checklist] The download record
  def self.checklist_download_async(core_otu_scope_params, request_url, extensions: [], accepted_name_mode: 'replace_with_accepted_name', project_id: nil)
    name = "dwc_checklist_#{DateTime.now}.zip"

    download = ::Download::DwcArchive::Checklist.create!(
      name: "DwC Checklist on #{Time.now}.",
      description: 'A zip file containing a Darwin Core Archive checklist.',
      filename: name,
      request: request_url,
      expires: 2.days.from_now
    )

    DwcaCreateChecklistDownloadJob.perform_later(
      download.id,
      core_otu_scope_params:,
      extensions:,
      accepted_name_mode:,
      project_id:
    )

    download
  end

  # Generate metadata for a record scope including sampling information
  # @param klass [Class] The ActiveRecord class
  # @param record_scope [ActiveRecord::Relation] Scope of records
  # @return [Hash] Metadata hash with :total, :start_time, and :sample keys
  def self.index_metadata(klass, record_scope)
    a = record_scope.first&.to_global_id&.to_s  # TODO: this should be UUID?
    b = record_scope.last&.to_global_id&.to_s # TODO: this should be UUID?

    t = record_scope.size # was having problems with count

    metadata = {
      total: t,
      start_time: Time.zone.now,
      sample: [a, b].compact
    }

    if b && (t > 2)
      max = 9
      max = t if t < 9

      ids = klass
        .select('*')
        .from("(select id, type, ROW_NUMBER() OVER (ORDER BY id ASC) rn from (#{record_scope.to_sql}) b ) a")
        .where("a.rn % ((SELECT COUNT(*) FROM (#{record_scope.to_sql}) c) / #{max}) = 0")
        .limit(max)
        .collect{|o| o.to_global_id.to_s}

      metadata[:sample].insert(1, *ids)
    end

    metadata[:sample].uniq!
    metadata
  end

end
