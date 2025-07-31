
shared_examples_for 'a successful response' do
  it 'returns HTTP Status 200 OK' do
    expect(response.successful?).to be_truthy 
  end

  #it 'returns JSON object indicating success' do
  #  expect(JSON.parse(response.body)).to eq('success' => true)
  #end

end

shared_examples_for 'unauthorized response' do
  it 'returns HTTP Status 401 Unauthorized' do
    expect(response).to be_unauthorized
  end

# it 'returns JSON object indicating failure' do
#   expect(JSON.parse(response.body)).to eq('success' => false)
# end
end

shared_examples_for 'secured by user and project token' do | factory, path |
  let(:user) { FactoryBot.create(:valid_user, :user_valid_token) }
  let!(:project) { FactoryBot.create(:valid_project, :project_valid_token, by: user) }
  let!(:project_member) { ProjectMember.create!(project: project, user: user, is_project_administrator: true, by: user) }

  let(:model) do
    case factory
      # TaxonName model has currently has cascading ancestor creation, which depends on Current_user/project_id being set.
      # They are not at this point, so we write an exception.  TODO: remove factory_bot ancestor spin-ups and use a shared_context instead
    when :valid_taxon_name
      Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: project.root_taxon_name, by: user, project: project)
    else
      FactoryBot.create(factory, by: user, project: project)
    end
  end

  let(:headers) { { "Authorization": 'Token ' + user.api_access_token } }

  context 'without a user token' do
    before { get path }
    it_behaves_like 'unauthorized response'
  end

  context 'with a valid user token, without project_id' do
    before { get path, headers: headers }
    it_behaves_like 'unauthorized response'
  end

  context 'with a valid user token and project_id' do
    before { get path, headers: headers, params: { project_id: model.project_id } }
    it_behaves_like 'a successful response'
  end

  context 'with a valid project token' do
    before { model.project.update(set_new_api_access_token: true) }
    before { get path, params: { project_token: model.project.api_access_token } }
    it_behaves_like 'a successful response'
  end
end
