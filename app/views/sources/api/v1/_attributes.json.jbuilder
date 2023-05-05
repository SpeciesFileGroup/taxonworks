# TODO: These need custom API versions
json.partial! '/sources/base_attributes', source: source
json.partial! '/shared/data/all/metadata', object: source, extensions: false

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

if extend_response_with('bibtex') && source.is_bibtex?
  json.bibtex source.to_bibtex.to_s
end
