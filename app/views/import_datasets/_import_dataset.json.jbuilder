# TODO: This view is DwC-A specific placed on a generic directory, it should not.
json.extract! import_dataset, :id, :type, :status, :description, :created_at, :updated_at, :progress
if ["Ready", "Staging"].include? import_dataset.status
  json.metadata do
    json.core_headers import_dataset.metadata["core_headers"]
    json.nomenclatural_code import_dataset.metadata["nomenclatural_code"]
    json.catalog_numbers_namespaces(import_dataset.metadata["catalog_numbers_namespaces"]) do |mapping|
      json.institutionalCode mapping[0][0]
      json.collectionCode mapping[0][1]
      json.namespace_id mapping[1]
    end
  end
end
json.url import_dataset_url(import_dataset, format: :json)
