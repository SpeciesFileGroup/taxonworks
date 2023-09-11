json.success true

json.open_projects do
  json.array! open_api_projects.pluck(:api_access_token, :name, :data_curation_issue_tracker_url) do |token, name, data_curation_issue_tracker_url|
    json.set! token, name
    json.data_curation_issue_tracker_url data_curation_issue_tracker_url
  end
end
