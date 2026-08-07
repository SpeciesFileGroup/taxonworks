json.array!(@biological_relationships) do |biological_relationship|
  json.partial! '/biological_relationships/api/v1/attributes', biological_relationship:
end
