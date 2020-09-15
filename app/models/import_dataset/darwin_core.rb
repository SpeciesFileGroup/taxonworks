class ImportDataset::DarwinCore < ImportDataset
  # self.abstract_class = true # TODO: Why causes app/views/shared/data/project/_show.html.erb to fail when visiting /import_datasets/list if uncommented?

  after_create -> (dwc) { ImportDatasetStageJob.perform_later(dwc) }

  CHECKLIST_ROW_TYPE = "http://rs.tdwg.org/dwc/terms/Taxon"
  OCCURRENCES_ROW_TYPE = "http://rs.tdwg.org/dwc/terms/Occurrence"

  # @return [Checklist|Occurrences|Unknown]
  # @param [string] file_path
  #   Path to DwC-A file
  # Returns the appropriate ImportDataset::DarwinCore subclass instantiated (not saved) for the supplied params
  def self.create_with_subtype_detection(params)
    core_type = nil

    return Unknown.new unless params[:source]

    begin
      if params[:source].content_type == "text/plain"
        headers = CSV.read(params[:source].tempfile.path, headers: true, col_sep: "\t", quote_char: nil, encoding: 'bom|utf-8').headers
        if headers.include? "occurrenceID"
          core_type = OCCURRENCES_ROW_TYPE
        elsif headers.include? "taxonID"
          core_type = CHECKLIST_ROW_TYPE
        end
      else
        dwc = ::DarwinCore.new(params[:source].tempfile.path)
        core_type = dwc.core.data[:attributes][:rowType]

        ### Check all files are readable
        [dwc.core, *dwc.extensions].each do |table|
          table.read { |data, errors| raise RuntimeError("Errors found when reading data") unless errors.empty? }
        end
      end
    rescue Errno::ENOENT, RuntimeError => e # TODO: dwc-archive gem should probably detect missing (or wrongly mapped) files and raise its own exception
      return Unknown.new(params.merge({error_message: "#{e.message}"}))
    end

    case core_type
    when OCCURRENCES_ROW_TYPE
      Occurrences.new(params)
    when CHECKLIST_ROW_TYPE
      Checklist.new(params)
    else
      Unknown.new(params.merge({error_message: "unknown DwC-A core type '#{core_type}'."}))
    end
  end

  # @return [Hash]
  # @param [Integer] max_time
  #   Maximum time to spend processing records.
  # @param [Integer] max_records
  #   Maximum number of records to be processed.
  # @param [Array] retry_failed
  #   Also looks up for failed records when importing (default is looking for records with Status=Ready)
  # @param [Hash] filters
  #   (Column-index, value) pairs of filters to apply when searching for records to import (default none)
  # Returns the updated dataset records.
  def import(max_time, max_records, retry_failed = false, filters = nil)
    raise NotImplementedError("Retrying failed records is not implemented") if retry_failed # Requires extra logic and posible new indicies to avoid being stuck processing always the same records
    status = ["Ready"]
    status << ["Failed"] if retry_failed

    records = dataset_records.where(status: status).order(:id).limit(max_records)
    filters&.each do |k, v|
      records = records.where("data_fields -> ? ->> 'value' = ?", k.to_i, v)
    end

    records = records.all
    start_time = Time.now
    imported = []

    records.each do |record|
      imported << record.import

      break if 1000.0*(Time.now - start_time).abs > max_time
    end

    imported
  end

  # @return [Hash]
  # Returns a hash with the record counts grouped by status
  def progress
    core_records.group(:status).count
  end

  # Stages DwC-A records into DB.
  def stage
    dataset_records.delete_all if status == "Staging" # ActiveJob being retried could cause this state

    update!(status: "Staging") if status == "Uploaded"

    if status != "Ready"
      perform_staging
      update!(status: "Ready")
    end
  end

  protected

  def get_records(source)
    records = { core: [], extensions: {} }
    headers = { core: [], extensions: {} }

    if ["application/zip", "application/octet-stream"].include? source.content_type
      dwc = ::DarwinCore.new(source.path)

      headers[:core] = get_dwc_headers(dwc.core)
      records[:core] = get_dwc_records(dwc.core)

      dwc.extensions.each do |extension|
        type = extension.properties[:rowType]
        records[:extensions][type] = get_dwc_records(extension)
        headers[:extensions][type] = get_dwc_headers(extension)
      end
    elsif ["text/plain"].include? source.content_type
      records[:core] = CSV.read(source.path, headers: true, col_sep: "\t", quote_char: nil).map { |r| r.to_h }
      headers[:core] = records[:core].first.to_h.keys
    else
      raise "Unsupported input format"
    end

    return records, headers
  end

  def get_dwc_headers(table)
    headers = []

    headers[table.id[:index]] = "id"
    # TODO: Think what to do about complex namespaces like "/std/Iptc4xmpExt/2008-02-29/" (currently returning the full URI as header)
    table.fields.each do |field|
      term = field[:term].match(/\/([^\/]+)\/terms\/([^\/]+)\/?$/)
      #headers[field[:index]] = term ? term[1..2].join(":") : field[:term]
      headers[field[:index]] = term ? term[2] : field[:term]
    end

    headers
  end

  def get_dwc_records(table)
    records = []
    headers = get_dwc_headers(table)

    records = table.read.first.map do |row|
      record = {}
      row.each_with_index { |v, i| record[headers[i]] = v }
      record
    end

    return records
  end

end
