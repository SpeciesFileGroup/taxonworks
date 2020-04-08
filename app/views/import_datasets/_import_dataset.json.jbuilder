json.extract! import_dataset, :id, :type, :status, :description, :created_at, :updated_at
json.metadata do
  json.core_headers import_dataset.metadata["core_headers"]
end
json.url import_dataset_url(import_dataset, format: :json)
