json.array!(@alternate_values) do |alternate_value|
  json.partial! 'attributes', alternate_value:
end
