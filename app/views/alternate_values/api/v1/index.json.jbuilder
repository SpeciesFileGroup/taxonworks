json.array!(@alternate_values) do |alternate_value|
  json.partial! '/alternate_values/api/v1/attributes', alternate_value:
end
