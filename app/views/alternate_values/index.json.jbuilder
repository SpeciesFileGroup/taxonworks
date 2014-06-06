json.array!(@alternate_values) do |alternate_value|
  json.extract! alternate_value, :id
  json.url alternate_value_url(alternate_value, format: :json)
end
