class ImportDataset::DarwinCore::Occurrences < ImportDataset::DarwinCore

  has_many :core_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Occurrence'
  has_many :extension_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Extension'

  MINIMUM_FIELD_SET = ["occurrenceID", "scientificName", "basisOfRecord"]

  validate :source, :check_field_set

  # Stages core (Occurrence) records and all extension records.
  def perform_staging
    records, headers = get_records(source)

    update!(metadata: {
      core_headers: headers[:core],
      extensions_headers: headers[:extensions],
      nomenclature_code: "ICZN",
      catalog_numbers_namespaces: []
    })

    core_records = records[:core].map do |record|
      {
        src_data: record,
        basisOfRecord: record["basisOfRecord"]
      }
    end

    catalog_numbers_namespaces = Set[]

    core_records.each do |record|
      dwc_occurrence = DatasetRecord::DarwinCore::Occurrence.new(import_dataset: self)
      dwc_occurrence.initialize_data_fields(record[:src_data].map { |k, v| v })

      catalog_numbers_namespaces << [
        [
          dwc_occurrence.get_field_value(:institutionCode),
          dwc_occurrence.get_field_value(:collectionCode)
        ],
        nil # User will select namespace through UI. TODO: Should we attempt guessing here?
      ]

      if "PreservedSpecimen".casecmp(record[:basisOfRecord]) == 0
        if dwc_occurrence.get_field_value(:catalogNumber).blank?
          dwc_occurrence.status = "Ready"
        else
          dwc_occurrence.status = "NotReady"
          record["error_data"] = { messages: { catalogNumber: ["Record cannot be imported until namespace is set."] } }
        end
      else
        dwc_occurrence.status = "Unsupported"
      end
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

    update!(metadata: self.metadata.merge!(catalog_numbers_namespaces: catalog_numbers_namespaces))
  end

  # @return [Hash]
  # Returns a hash with the record counts grouped by status
  def progress
    core_records.group(:status).count
  end

  def check_field_set
    if source.staged?

      if source.staged_path =~ /\.zip\z/i
        headers = get_dwc_headers(::DarwinCore.new(source.staged_path).core)
      else
        if source.staged_path =~ /\.(xlsx?|ods)\z/i
          headers = CSV.parse(Roo::Spreadsheet.open(source.staged_path).to_csv, headers: true).headers
        else
          headers = CSV.read(source.staged_path, headers: true, col_sep: "\t", quote_char: nil, encoding: 'bom|utf-8').headers
        end
      end

      missing_headers = MINIMUM_FIELD_SET - headers

      missing_headers.each do |header|
        errors.add(:source, "required field #{header} missing.")
      end
    end
  end

  def get_catalog_number_namespace(institution_code, collection_code)
    get_catalog_number_namespace_mapping(institution_code, collection_code)&.at(1)
  end

  def update_catalog_number_namespace(institution_code, collection_code, namespace_id)
    transaction do
      mapping = get_catalog_number_namespace_mapping(institution_code, collection_code)
      mapping[1] = namespace_id
      ready = namespace_id.to_i > 0
      save!

      fields_mapping = self.metadata["core_headers"].each.with_index.inject({}) { |m, (h, i)| m.merge({ h => i, i => h}) }

      query = ready ? dataset_records.where(status: 'NotReady') : dataset_records.where.not(status: ['NotReady', 'Imported', 'Unsupported'])
      query.where(
        "(:institution_code_field IS NULL OR data_fields -> :institution_code_field ->> 'value' = :institution_code) AND" +
        "(:collection_code_field IS NULL OR data_fields -> :collection_code_field ->> 'value' = :collection_code)",
        {
          institution_code_field: fields_mapping["institutionCode"], institution_code: institution_code,
          collection_code_field: fields_mapping["collectionCode"], collection_code: collection_code
        }
      ).update_all(ready ?
        "status = 'Ready', metadata = metadata - 'error_data'" :
        "status = 'NotReady', metadata = jsonb_set(metadata, '{error_data}', '{ \"messages\": { \"catalogNumber\": [\"Record cannot be imported until namespace is set, see \\\"Settings\\\".\"] } }')"
      )
    end
  end

  def add_catalog_number_namespace(institution_code, collection_code, namespace_id = nil)
    unless get_catalog_number_namespace_mapping(institution_code, collection_code)
      self.metadata["catalog_numbers_namespaces"] << [[institution_code, collection_code], namespace_id]
    end
    save!
  end

  private

  def get_catalog_number_namespace_mapping(institution_code, collection_code)
    self.metadata["catalog_numbers_namespaces"]&.detect { |m| m[0] == [institution_code, collection_code] }
  end

end
