json.array!(@data_attributes) do |data_attribute|
  json.partial! 'attributes', data_attribute: data_attribute
end
