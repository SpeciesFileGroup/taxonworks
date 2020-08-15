class ImportDataset::DarwinCore::Occurrences < ImportDataset::DarwinCore

  has_many :core_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Occurrence'
  has_many :extension_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Extension'

  # Stages core (Occurrence) records and all extension records.
  def perform_staging
    records, headers = get_records(source)

    update!(metadata: {
      core_headers: headers[:core],
      extensions_headers: headers[:extensions],
      nomenclature_code: "ICZN"
    })

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
      dwc_occurrence = DatasetRecord::DarwinCore::Occurrence.new(import_dataset: self)
      dwc_occurrence.initialize_data_fields(record[:src_data].map { |k, v| v })
      dwc_occurrence.status = !record[:invalid] ? "Ready" : "NotReady"
      record.delete(:src_data)
      dwc_occurrence.metadata = record

      dwc_occurrence.save!
    end

    records[:extensions].each do |extension_type, records|
      records.each do |record|
        dwc_extension = DatasetRecord::DarwinCore::Extension.new(import_dataset: self)
        dwc_extension.initialize_data_fields(record.map { |k, v| v })
        dwc_extension.status = "Unsupported"
        dwc_extension.metadata = { "type" => extension_type }

        dwc_extension.save!
      end
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
