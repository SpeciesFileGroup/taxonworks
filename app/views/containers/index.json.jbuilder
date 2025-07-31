json.array!(@containers) do |container|
  json.partial! '/containers/attributes', container:
end
