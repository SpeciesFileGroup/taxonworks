json.array!(@datasets) do |dataset|
  json.extract! dataset, :id, :description, :type, :status

  json.progress dataset.progress(filters: @filters)

  json.source_file dataset.source.url
  json.created_at dataset.created_at
  json.updated_at dataset.dataset_records.maximum(:updated_at) || dataset.created_at
end