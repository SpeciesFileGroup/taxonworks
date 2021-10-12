json.partial! '/people/base_attributes', person: person

if extend_response_with('roles')
  json.roles do
    json.array!(person.roles) do |role|
      json.partial! '/roles/attributes', role: role
    end
  end
end
