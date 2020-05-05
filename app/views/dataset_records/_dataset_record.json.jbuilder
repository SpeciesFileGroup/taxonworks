# TODO: Do not expose complete metadata. Doing so at this time to simplify development.
json.extract! dataset_record, :id, :status, :metadata, :data_fields
# json.id dataset_record.id
# json.data_fields do
#   json.array! dataset_record.data_fields.keys.collect do |key|
#     json.field key
#     json.extract! dataset_record.data_fields[key], "value", "frozen"
#   end
# end
