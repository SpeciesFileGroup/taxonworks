json.extract! dataset_record, :id, :data, :created_at, :updated_at
json.url dataset_record_url(dataset_record, format: :json)
