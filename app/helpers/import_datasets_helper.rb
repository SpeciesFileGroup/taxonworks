module ImportDatasetsHelper

  def import_dataset_tag(import_dataset)
    return nil if import_dataset.nil?
    import_dataset.description
  end

  def import_dataset_link(import_dataset)
    return nil if import_dataset.nil?
    link_to(import_dataset_tag(import_dataset).html_safe, import_dataset.becomes(ImportDataset))
  end

  def import_dataset_download(import_dataset)
    return nil if import_dataset.nil?
    link_to(
      '',
      import_dataset.source.url(),
      class: ['circle-button', 'btn-download'],
      download: import_dataset.source_file_name,
      title: import_dataset.source_file_name) 
  end

end
