json.array!(@biological_relationships) do |biological_relationship|
  json.partial! '/biological_relationships/attributes', biological_relationship: biological_relationship
end
