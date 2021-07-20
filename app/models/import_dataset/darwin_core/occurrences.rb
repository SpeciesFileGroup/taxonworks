class ImportDataset::DarwinCore::Occurrences < ImportDataset::DarwinCore
  is_origin_for Person::Unvetted.to_s

  has_many :core_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Occurrence'
  has_many :extension_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Extension'

  MINIMUM_FIELD_SET = ["occurrenceID", "scientificName", "basisOfRecord"]

  validate :source, :check_field_set

  def core_records_class
    DatasetRecord::DarwinCore::Occurrence
  end

  def core_records_identifier_name
    'occurrenceID'
  end

  # Stages core (Occurrence) records and all extension records.
  def perform_staging
    records, headers = get_records(source)

    update!(metadata:
      metadata.merge({
        core_headers: headers[:core],
        extensions_headers: headers[:extensions],
        nomenclature_code: "ICZN",
        catalog_numbers_namespaces: []
      })
    )

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

      if "PreservedSpecimen".casecmp(record[:basisOfRecord]) == 0 || record[:basisOfRecord].blank?
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

      fields_mapping = self.metadata["core_headers"].each.with_index.inject({}) { |m, (h, i)| m.merge({ h.downcase => i, i => h}) }

      query = ready ? core_records.where(status: 'NotReady') : core_records.where.not(status: ['NotReady', 'Imported', 'Unsupported'])

      # TODO: Add scopes/methods in DatasetRecord to handle nil fields values transparently
      unless institution_code.nil?
        query = query.where(
          id: core_records_fields.at(fields_mapping["institutioncode"]).with_value(institution_code).select(:dataset_record_id)
        )
      else
        query = query.where.not(
          id: core_records_fields.at(fields_mapping["institutioncode"]).select(:dataset_record_id)
        )
      end
      unless collection_code.nil?
        query = query.where(
          id: core_records_fields.at(fields_mapping["collectioncode"]).with_value(collection_code).select(:dataset_record_id)
        )
      else
        query = query.where.not(
          id: core_records_fields.at(fields_mapping["collectioncode"]).select(:dataset_record_id)
        )
      end

      query.update_all(ready ?
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

  def containerize_dup_cat_no?
    !!self.metadata.dig("import_settings", "containerize_dup_cat_no")
  end

  def restrict_to_existing_nomenclature?
    !!self.metadata.dig("import_settings", "restrict_to_existing_nomenclature")
  end

  private

  def get_catalog_number_namespace_mapping(institution_code, collection_code)
    self.metadata["catalog_numbers_namespaces"]&.detect { |m| m[0] == [institution_code, collection_code] }
  end

end
