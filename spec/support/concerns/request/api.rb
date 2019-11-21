
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
  let(:model) { FactoryBot.create(factory) }
  let(:user) { User.first }
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
