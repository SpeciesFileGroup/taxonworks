json.array!(@data_attributes) do |data_attribute|
  json.partial! '/data_attributes/api/v1/attributes', data_attribute: data_attribute
end
