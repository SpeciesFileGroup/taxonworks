json.array!(@taxon_name_classifications) do |taxon_name_classification|
  json.extract! taxon_name_classification, :id, :taxon_name_id, :type, :created_by_id, :updated_by_id, :project_id
  json.url taxon_name_classification_url(taxon_name_classification, format: :json)
end
