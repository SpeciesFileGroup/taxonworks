class ImportDataset::DarwinCore::Occurrences < ImportDataset::DarwinCore

  has_many :core_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Occurrence'
  has_many :extension_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Extension'

  def initialize(params)
    super(params)

    if params[:source]
      records, headers = get_records(params[:source])

      parse_results = Biodiversity::Parser.parse_ary(records[:core].map { |r| r["scientificName"] || "" })
      records_lut = { }

      core_records = records[:core].each_with_index.map do |record, index|
        records_lut[record["taxonID"]] = {
          index: index,
          type: nil,
          parse_results: parse_results[index],
          src_data: record
        }
      end

      core_records.each do |record|
        parse_results = record[:parse_results]

        record[:invalid] = "scientificName could not be parsed" if not parse_results[:details]
      end

      core_records.each do |record|
        dwc_occurrence = DatasetRecord::DarwinCore::Occurrence.new
        dwc_occurrence.initialize_data_fields(record[:src_data].map { |k, v| v })
        dwc_occurrence.status = !record[:invalid] ? "Ready" : "NotReady"
        record.delete(:src_data)
        dwc_occurrence.metadata = record

        dataset_records << dwc_occurrence
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
        nomenclature_code: "ICZN"
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

end
