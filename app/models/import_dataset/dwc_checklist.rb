class ImportDataset::DwcChecklist < ImportDataset

  # TODO: Revisit this (check existing STI in TW and whether this is safe or not).
  #       Taken from https://stackoverflow.com/questions/4507149/best-practices-to-handle-routes-for-sti-subclasses-in-rails
  def self.model_name
    ImportDataset.model_name
  end

  def initialize(params)
    super(params)

    if params[:source]
      records = CSV.read(params[:source].tempfile, headers: true, col_sep: "\t")
      headers = records.first.to_h.keys

      parse_results = Biodiversity::Parser.parse_ary(records["scientificName"])
      records_lut = { }

      records = records.each_with_index.map do |record, index|
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
          src_data: record.to_hash
        }
      end


      records.each do |record|
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
          records[parent][:dependants] << record[:index]
        end
      end

      records.each do |record|
        dwc_taxon = DatasetRecord::DwcTaxon.new
        dwc_taxon.initialize_data_fields(record[:src_data])
        dwc_taxon.status = !record[:invalid] && !record[:is_synonym] && record[:parent].nil? ? "Ready" : "NotReady"
        record.delete(:src_data)
        dwc_taxon.metadata = record

        dataset_records << dwc_taxon
      end

      self.metadata = {
        core_headers: headers,
        nomenclature_code: "ICN"
      }
    end
  end

  # @param [Integer] max
  #   Maximum amount of records to import.
  def import(max)
    dataset_records.where(status: "Ready").limit(max).map { |r| r.import }
  end
end
