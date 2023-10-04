json.success true

json.open_projects do
  json.array! open_api_projects.pluck(:api_access_token, :name, :data_curation_issue_tracker_url) do |project_token, name, data_curation_issue_tracker_url|
    json.name name
    json.project_token project_token
    json.data_curation_issue_tracker_url data_curation_issue_tracker_url
  end
end
