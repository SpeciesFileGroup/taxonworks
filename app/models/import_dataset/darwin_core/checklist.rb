class ImportDataset::DarwinCore::Checklist < ImportDataset::DarwinCore

  has_many :core_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Taxon'
  has_many :extension_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Extension'

  def initialize(params)
    super(params)

    if params[:source]
      records, headers = get_records(params[:source])

      parse_results = Biodiversity::Parser.parse_ary(records[:core].map { |r| r["scientificName"] })
      records_lut = { }

      core_records = records[:core].each_with_index.map do |record, index|
        records_lut[record["taxonID"]] = {
          index: index,
          type: nil,
          dependencies: [],
          dependants: [],
          synonyms: [],
          is_hybrid: nil,
          is_synonym: nil,
          parent: record["parentNameUsageID"],
          parse_results: parse_results[index],
          src_data: record
        }
      end

      core_records.each do |record|
        acceptedNameUsage = records_lut[record[:src_data]["acceptedNameUsageID"]]

        if acceptedNameUsage
          record[:parent] = acceptedNameUsage[:parent]
          record[:is_synonym] = acceptedNameUsage[:index] != record[:index]
          acceptedNameUsage[:synonyms] << record[:index] if record[:is_synonym]
        else
          record[:invalid] = "acceptedNameUsageID '#{record[:src_data]["acceptedNameUsageID"]}' not found"
        end

        record[:parent] = nil if record[:parent].blank?

        parse_results = record[:parse_results]

        record[:is_hybrid] = parse_results[:hybrid]

        if not parse_results[:details]
          record[:type] = :unknown
          record[:invalid] = "Name could not be parsed"
        elsif (parse_results[:authorship] || "")[0] == "("
          record[:type] = :combination
        else
          record[:type] = :protonym
        end

        case record[:type]
        when :protonym
          record[:originalCombination] = record[:index]
        when :combination
          #***FIND ORIGINAL COMBINATION
        end

        unless record[:parent].nil?
          parent = records_lut[record[:parent]][:index]
          record[:dependencies] << parent
          core_records[parent][:dependants] << record[:index]
        end
      end

      core_records.each do |record|
        dwc_taxon = DatasetRecord::DarwinCore::Taxon.new
        dwc_taxon.initialize_data_fields(record[:src_data].map { |k, v| v })
        dwc_taxon.status = !record[:invalid] && !record[:is_synonym] && record[:parent].nil? ? "Ready" : "NotReady"
        record.delete(:src_data)
        dwc_taxon.metadata = record

        dataset_records << dwc_taxon
      end

      records[:extensions].each do |extension_type, records|
        records.each do |record|
          dwc_extension = DatasetRecord::DarwinCore::Extension.new
          dwc_extension.initialize_data_fields(record.map { |k, v| v })
          dwc_extension.status = "Unsupported"
          dwc_extension.metadata = { "type" => extension_type }

          dataset_records << dwc_extension
        end
      end

      self.metadata = {
        core_headers: headers[:core],
        extensions_headers: headers[:extensions],
        nomenclature_code: "ICN"
      }
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

  private

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
      records[:core] = CSV.read(source_path, headers: true, col_sep: "\t").map { |r| r.to_h }
      headers[:core] = records.first.to_h.keys
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
