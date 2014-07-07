json.array!(@project_members) do |project_member|
  json.extract! project_member, :id, :project_id, :user_id, :created_by_id, :updated_by_id, :is_project_administrator
  json.url project_member_url(project_member, format: :json)
end
