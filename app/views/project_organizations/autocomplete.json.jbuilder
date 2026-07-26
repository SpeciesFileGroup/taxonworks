json.array! @project_organizations do |project_organization|
  json.gid project_organization.to_global_id.to_s
  json.id project_organization.id
  json.label label_for_project_organization(project_organization)
  json.label_html project_organization_autocomplete_tag(project_organization)

  json.response_values do
    if params[:method]
      json.set! params[:method], project_organization.id
    end
  end
end
