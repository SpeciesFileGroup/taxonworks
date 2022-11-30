json.partial! '/sources/base_attributes', source: source
json.partial! '/shared/data/all/metadata', object: source

json.source_in_project source_in_project?(source)
json.project_source_id project_source_for_source(source)&.id

if extend_response_with('roles')
  json.partial! '/sources/roles_attributes', source: source
end

if extend_response_with('documents')
  json.documents do |d|
    d.array! source.documents.where(documents: {project_id: sessions_current_project_id}), partial: '/documents/attributes', as: :document
  end
end