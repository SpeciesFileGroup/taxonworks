class ImportDataset::DarwinCore::Checklist < ImportDataset::DarwinCore

  has_many :core_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Taxon'
  has_many :extension_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Extension'

  # Stages core (Taxon) records and all extension records.
  def perform_staging
    records, headers = get_records(source)

    update!(metadata: {
      core_headers: headers[:core],
      extensions_headers: headers[:extensions],
      nomenclature_code: "ICN"
    })

    parse_results_ary = Biodiversity::Parser.parse_ary(records[:core].map { |r| r["scientificName"] || "" })
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
        src_data: record
      }
    end

    core_records.each_with_index do |record, index|
      acceptedNameUsage = records_lut[record[:src_data]["acceptedNameUsageID"]]

      if acceptedNameUsage
        record[:parent] = acceptedNameUsage[:parent]
        record[:is_synonym] = acceptedNameUsage[:index] != record[:index]
        acceptedNameUsage[:synonyms] << record[:index] if record[:is_synonym]
      else
        record[:invalid] = "acceptedNameUsageID '#{record[:src_data]["acceptedNameUsageID"]}' not found"
      end

      record[:parent] = nil if record[:parent].blank?

      parse_results = parse_results_ary[index]

      record[:is_hybrid] = !!parse_results[:hybrid]

      if not parse_results[:details]
        record[:type] = :unknown
        record[:invalid] = "Name could not be parsed"
      elsif (parse_results.dig(:authorship, :normalized) || "")[0] == "("
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
      dwc_taxon = DatasetRecord::DarwinCore::Taxon.new(import_dataset: self)
      dwc_taxon.initialize_data_fields(record[:src_data].map { |k, v| v })
      dwc_taxon.status = !record[:invalid] && !record[:is_synonym] && record[:parent].nil? ? "Ready" : "NotReady"
      record.delete(:src_data)
      dwc_taxon.metadata = record

      dwc_taxon.save!
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

end
