json.progress @import_dataset.progress(filters: @filters)
json.records do
  json.array! @dataset_records, partial: "dataset_records/dataset_record", as: :dataset_record
end
