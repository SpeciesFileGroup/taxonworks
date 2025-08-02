shared_context 'api context' do
  let(:user) { FactoryBot.create(:valid_user, :user_valid_token) }
  let!(:project) { FactoryBot.create(:valid_project, :project_valid_token, by: user) }
  let!(:project_member) { ProjectMember.create!(project: project, user: user, is_project_administrator: true, by: user) }
  let(:headers) { { "Authorization": 'Token ' + user.api_access_token } }
end

