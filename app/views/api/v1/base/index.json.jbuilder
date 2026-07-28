json.success true

json.open_projects do
  json.array! open_api_projects.includes(project_organizations: [:organization]) do |project|
    json.name project.name
    json.project_token project.api_access_token
    json.data_curation_issue_tracker_url project.data_curation_issue_tracker_url

    if extend_response_with('organizations')

      json.organizations project.project_organizations do |project_organization|
        organization = project_organization.organization

        json.extract! organization, :id, :name, :alternate_name, :legal_name,
          :address, :email, :telephone, :geographic_area_id

        json.country organization.geographic_area&.country 

        json.global_id organization.to_global_id.to_s

        json.depictions project_organization.depictions do |depiction|
          json.extract! depiction, :id, :caption, :figure_label

          json.image do
            json.id depiction.image.id
            json.content_type depiction.image.image_file_content_type
            json.image_file_url root_url + depiction.image.image_file.url[1..-1]
          end
        end
      end
    end
  end
end
