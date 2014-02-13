json.array!(@biocuration_classes) do |biocuration_class|
  json.extract! biocuration_class, :id, :name, :created_by_id, :updated_by_id, :project_id
  json.url biocuration_class_url(biocuration_class, format: :json)
end
