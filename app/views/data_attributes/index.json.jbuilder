json.array!(@data_attributes) do |data_attribute|
  json.extract! data_attribute, :id
  json.url data_attribute_url(data_attribute, format: :json)
end
