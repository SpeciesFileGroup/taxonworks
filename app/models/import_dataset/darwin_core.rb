class ImportDataset::DarwinCore < ImportDataset
  # self.abstract_class = true # TODO: Why causes app/views/shared/data/project/_show.html.erb to fail when visiting /import_datasets/list if uncommented?

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
        headers = CSV.read(params[:source].tempfile.path, headers: true, col_sep: "\t", quote_char: nil).headers
        if headers.include? "occurrenceID"
          core_type = OCCURRENCES_ROW_TYPE
        elsif headers.include? "taxonID"
          core_type = CHECKLIST_ROW_TYPE
        end
      else
        core_type = ::DarwinCore.new(params[:source].tempfile.path).core.data[:attributes][:rowType]
      end
    rescue RuntimeError => e
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
  # @param [Integer] max
  #   Maximum amount of records to import.
  # Returns the updated dataset records by the import process.
  def import(max)
    dataset_records.where(status: "Ready").limit(max).map { |r| r.import }
  end

  # @return [Hash]
  # Returns a hash with the record counts grouped by status
  def progress
    core_records.group(:status).count
  end

  protected

  def get_records(source)
    source_path = source.tempfile.path
    records = { core: [], extensions: {} }
    headers = { core: [], extensions: {} }

    if ["application/zip", "application/octet-stream"].include? source.content_type
      dwc = ::DarwinCore.new(source_path)

      records[:core], headers[:core] = get_dwc_records(dwc.core)

      dwc.extensions.each do |extension|
        type = extension.properties[:rowType]
        records[:extensions][type], headers[:extensions][type] = get_dwc_records(extension)
      end
    elsif ["text/plain"].include? source.content_type
      records[:core] = CSV.read(source_path, headers: true, col_sep: "\t", quote_char: nil).map { |r| r.to_h }
      headers[:core] = records[:core].first.to_h.keys
    else
      raise "Unsupported input format"
    end

    return records, headers
  end

  def get_dwc_records(table)
    records = []
    headers = []

    headers[table.id[:index]] = "id"
    # TODO: Think what to do about complex namespaces like "/std/Iptc4xmpExt/2008-02-29/" (currently returning the full URI as header)
    table.fields.each do |field|
      term = field[:term].match(/\/([^\/]+)\/terms\/([^\/]+)\/?$/)
      #headers[field[:index]] = term ? term[1..2].join(":") : field[:term]
      headers[field[:index]] = term ? term[2] : field[:term]
    end

    records = table.read.first.map do |row|
      record = {}
      row.each_with_index { |v, i| record[headers[i]] = v }
      record
    end

    return records, headers
  end

end
