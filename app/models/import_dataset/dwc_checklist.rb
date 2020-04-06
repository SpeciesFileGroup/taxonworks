class ImportDataset::DwcChecklist < ImportDataset

  # TODO: Revisit this (check existing STI in TW and whether this is safe or not).
  #       Taken from https://stackoverflow.com/questions/4507149/best-practices-to-handle-routes-for-sti-subclasses-in-rails
  def self.model_name
    ImportDataset.model_name
  end

  def initialize(params)
    super(params)

    if params[:source]
      CSV.read(params[:source].tempfile, headers: true, col_sep: "\t").each do |row|
        record = DatasetRecord::DwcTaxon.new(status: "Pending")
        record.initialize_data_fields(row.to_h)
        dataset_records << record
      end
    end
  end
end