if source.type == 'Source::Bibtex'
  json.author_roles(source.author_roles) do |role|
    json.extract! role, :id, :position, :type
    json.person do
      json.partial! '/people/base_attributes', person: role.person
    end
  end

  json.editor_roles(source.editor_roles) do |role|
    json.extract! role, :id, :position, :type
    json.person do
      json.partial! '/people/base_attributes', person: role.person
    end
  end
end


