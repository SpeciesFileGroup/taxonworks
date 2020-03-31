class ImportDataset::DwcChecklist < ImportDataset

  # TODO: Revisit this (check existing STI in TW and whether this is safe or not).
  #       Taken from https://stackoverflow.com/questions/4507149/best-practices-to-handle-routes-for-sti-subclasses-in-rails
  def self.model_name
    ImportDataset.model_name
  end
end