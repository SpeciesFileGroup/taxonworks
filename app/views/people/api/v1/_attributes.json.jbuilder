json.partial! '/people/api/v1/base_attributes', person: person

# TODO: Move to RESTful /roles
if params['include_roles'] == 'true'
  json.roles do
    json.array!(person.roles) do |role|
      json.partial! '/roles/api/v1/attributes', role: role
    end
  end
end
