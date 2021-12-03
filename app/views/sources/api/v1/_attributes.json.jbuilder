json.partial! '/sources/base_attributes', source: source
json.partial! '/shared/data/all/metadata', object: source

json.source_in_project source_in_project?(source)
json.project_source_id project_source_for_source(source)&.id

if extend_response_with('roles')
  if source.type == 'Source::Bibtex'
    json.author_roles(source.author_roles) do |role|
      json.extract! role, :id, :position, :type
      json.person do
        json.partial! '/people/api/v1/brief', person: role.person 
      end
    end

    json.editor_roles(source.editor_roles) do |role|
      json.extract! role, :id, :position, :type
      json.person do
        json.partial! '/people/api/v1/brief', person: role.person 
      end
    end
  end
end

if extend_response_with('documents')
  json.documents do |d|
    d.array! source.documents, partial: '/documents/attributes', as: :document
  end
end
