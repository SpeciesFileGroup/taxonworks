json.partial! '/people/base_attributes', person: person
json.partial! '/shared/data/all/metadata', object: person

if extend_response_with('roles')
  json.roles do
    json.array!(person.roles) do |role|
      json.partial! '/roles/attributes', role: role
    end
  end
end
if extend_response_with('role_counts')
  json.role_counts person.role_counts(sessions_current_project_id)
end
