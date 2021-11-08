json.id dataset_record.id
json.status dataset_record.status
json.metadata do
  json.error_data dataset_record.metadata["error_data"] if dataset_record.metadata["error_data"]
  json.imported_objects dataset_record.metadata["imported_objects"] if dataset_record.metadata["imported_objects"]
end
json.data_fields dataset_record.data_fields
