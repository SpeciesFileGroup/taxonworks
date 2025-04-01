json.partial! '/people/api/v1/base_attributes', person: person

if extend_response_with('roles')
  json.roles do
    json.array!(person.roles) do |role|
      json.partial! '/roles/api/v1/attributes', role: role
    end
  end
end

if extend_response_with('identifiers')
  json.identifiers do
    json.merge! extend_identifiers(person)
  end
end
