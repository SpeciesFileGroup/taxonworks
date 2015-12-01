json.array!(@documents) do |document|
  json.extract! document, :id, :document_file, :project_references, :created_by_id, :updated_by_id
  json.url document_url(document, format: :json)
end
