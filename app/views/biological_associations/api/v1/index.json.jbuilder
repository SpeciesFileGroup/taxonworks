json.array!(@biological_associations) do |biological_association|
  json.partial! '/biological_associations/api/v1/attributes', biological_association: biological_association
end
