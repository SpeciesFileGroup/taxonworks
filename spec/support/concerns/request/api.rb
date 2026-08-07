
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

shared_examples_for 'a 422 response' do
  it 'returns HTTP Status 422 Error' do
    expect(response.status).to eq(422)
  end
end

shared_examples_for 'secured by user/project token' do | factory, path, method, require_both |
  method ||= 'get'
  require_both ||= false # require both user and project

  include_context 'api context'

  let(:model) do
    case factory
      # TaxonName model has currently has cascading ancestor creation, which depends on Current_user/project_id being set.
      # They are not at this point, so we write an exception.  TODO: remove factory_bot ancestor spin-ups and use a shared_context instead
    when :valid_taxon_name
      Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: project.root_taxon_name, by: user, project: project)
    else
      if factory
        FactoryBot.create(factory, by: user, project: project)
      end
    end
  end

  context 'without a user token' do
    before { send(method, path) }
    it_behaves_like 'unauthorized response'
  end

   context 'with a valid user token, without project_id' do
     before { send(method, path, headers: headers) }
     it_behaves_like 'unauthorized response'
   end

  context 'with a valid user token and project_id' do
    before { send(method, path, headers: headers, params: { project_id: project.id }) }
    if require_both
      it_behaves_like 'unauthorized response'
    else
      it_behaves_like 'a successful response'
    end
  end

  context 'with a valid project token' do
    before { send(method, path, params: { project_token: project.api_access_token }) }
    if require_both
      it_behaves_like 'unauthorized response'
    else
      it_behaves_like 'a successful response'
    end
  end

  context 'with a valid project token and a valid user token' do
    before { project.update(set_new_api_access_token: true) }
    before { send(method, path, headers: headers, params: { project_token: project.api_access_token }) }

    it_behaves_like 'a successful response'
  end
end

shared_examples_for 'unprocessable entity' do | factory, path, method, require_both |
  method ||= 'get'
  require_both ||= false # require both user and project

  include_context 'api context'

  let(:model) do
    case factory
      # TaxonName model has currently has cascading ancestor creation, which depends on Current_user/project_id being set.
      # They are not at this point, so we write an exception.  TODO: remove factory_bot ancestor spin-ups and use a shared_context instead
    when :valid_taxon_name
      Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: project.root_taxon_name, by: user, project: project)
    else
      if factory
        FactoryBot.create(factory, by: user, project: project)
      end
    end
  end

  context 'with a valid project token and a valid user token' do
    before { send(method, path, headers: headers, params: { project_token: project.api_access_token }) }

    it_behaves_like 'a 422 response'
  end
end