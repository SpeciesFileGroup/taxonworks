json.id dataset_record.id
json.status dataset_record.status
json.metadata dataset_record.metadata # TODO: Do not expose complete metadata. Doing so at this time to simplify development.
json.data_fields do
  json.array! dataset_record.data_fields do |field|
    json.value field
  end
end
