json.extract! project_organization, :id, :organization_id, :project_id,
  :created_by_id, :updated_by_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: project_organization

json.organization do
  json.partial! '/organizations/attributes', organization: project_organization.organization
end

json.logos project_organization.logos do |logo|
  json.partial! '/depictions/attributes', depiction: logo
end
