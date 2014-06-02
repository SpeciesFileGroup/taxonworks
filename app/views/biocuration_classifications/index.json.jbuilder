json.array!(@biocuration_classifications) do |biocuration_classification|
  json.extract! biocuration_classification, :id, :biocuration_class_id, :biological_collection_object_id, :position, :created_by_id, :updated_by_id, :project_id
  json.url biocuration_classification_url(biocuration_classification, format: :json)
end
