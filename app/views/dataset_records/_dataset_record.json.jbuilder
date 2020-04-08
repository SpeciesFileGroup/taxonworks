json.extract! dataset_record, :id, :data_fields
# json.id dataset_record.id
# json.data_fields do
#   json.array! dataset_record.data_fields.keys.collect do |key|
#     json.field key
#     json.extract! dataset_record.data_fields[key], "value", "frozen"
#   end
# end
