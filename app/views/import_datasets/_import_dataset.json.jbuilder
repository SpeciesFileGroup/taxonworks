# TODO: This view is DwC-A specific placed on a generic directory, it should not.
json.extract! import_dataset, :id, :type, :status, :description, :created_at, :updated_at, :progress
json.metadata do
  json.core_headers import_dataset.metadata["core_headers"]
end
json.core_records_count import_dataset.core_records.count
json.url import_dataset_url(import_dataset, format: :json)
