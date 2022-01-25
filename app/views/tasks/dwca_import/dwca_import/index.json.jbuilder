json.array!(@datasets) do |dataset|
  json.extract! dataset, :id, :description, :type, :status

  json.progress dataset.progress(filters: @filters)

  json.source_file dataset.source.url
  json.created_at "#{time_ago_in_words(dataset.created_at)} ago"
  json.updated_at "#{time_ago_in_words(dataset.dataset_records.maximum(:updated_at) || dataset.created_at)} ago"
end