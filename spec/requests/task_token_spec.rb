require 'rails_helper'

# task_token authentication, see TaskTokenAuthentication and lib/task_token.
describe 'task_token authentication', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:password) { 'abcD123!' }
  let(:origin) { 'quick_mobile_material_task' }
  let(:task_path) { '/tasks/collection_objects/quick_mobile_material' }
  let(:capture_path) { "#{task_path}/capture" }

  let!(:administrator) {
    User.create!(name: 'Pat the Administrator', email: 'administrator@example.com',
                 password:, password_confirmation: password, is_administrator: true, self_created: true)
  }

  let!(:user) {
    User.create!(name: 'Pat User', email: 'user@example.com',
                 password:, password_confirmation: password, self_created: true)
  }

  let!(:other_user) {
    User.create!(name: 'Sam User', email: 'sam@example.com',
                 password:, password_confirmation: password, self_created: true)
  }

  let!(:project) {
    Project.create!(name: 'My Project', creator: administrator, updater: administrator, without_root_taxon_name: true)
  }

  let!(:other_project) {
    Project.create!(name: 'Other Project', creator: administrator, updater: administrator, without_root_taxon_name: true)
  }

  let!(:composition) {
    Layout::Task.create!(name: 'Mobile', project:, creator: user, updater: user)
  }

  # Not memoized, examples make several requests
  def body
    JSON.parse(response.body)
  end

  let(:ids) { { user_id: user.id, project_id: project.id, composition_id: composition.id } }

  before do
    [user, other_user].each do |u|
      [project, other_project].each do |p|
        p.project_members.create!(creator: administrator, updater: administrator, user: u)
      end
    end
  end

  after { Rails.cache.clear }

  def sign_in(u = user)
    post '/sessions', params: { session: { email: u.email, password: } }
  end

  def select_project(p = project)
    get "/projects/#{p.id}/select"
  end

  def pending_token(u = user, attributes: { 'composition_id' => composition.id })
    TaskToken.issue(user_id: u.id, project_id: project.id, origin:, attributes:).token
  end

  def initiate(token, params = ids)
    post capture_path, params: params.to_json, headers: { 'X-Task-Token' => token, 'CONTENT_TYPE' => 'application/json' }
  end

  def active_token(u = user)
    initiate(pending_token(u), ids.merge(user_id: u.id))
    JSON.parse(response.body)['task_token']
  end

  def upload(path = Rails.root.join('spec/files/images/tiny.png'))
    Rack::Test::UploadedFile.new(path, 'image/png')
  end

  def capture(token, params = {})
    post capture_path, params: ids.merge(image: upload).merge(params), headers: { 'X-Task-Token' => token }
  end

  context 'session actions (in TaxonWorks)' do
    context 'signed out' do
      specify 'issuing a token is refused' do
        post "#{task_path}/task_token.json", params: { composition_id: composition.id }
        expect(response).to have_http_status(:unauthorized)
        expect(Rails.cache.read(TaskToken::Store.origin_key(user.id, origin))).to be_nil
      end
    end

    context 'signed in, project selected' do
      before { sign_in; select_project }

      specify 'the Task page renders' do
        get task_path
        expect(response).to have_http_status(:ok)
      end

      specify 'issue returns an SVG QR code and expiry, the token is pending' do
        post "#{task_path}/task_token.json", params: { composition_id: composition.id }
        expect(response).to have_http_status(:ok)
        expect(body['svg']).to start_with('<?xml')
        expect(body['svg']).to include('<svg')
        expect(Time.iso8601(body['expires_at'])).to be_within(5.seconds).of(Time.current + 2.minutes)
        expect(body['task_token_status']['state']).to eq('pending')
        expect(body['task_token_status'].keys).not_to include('jti')
      end

      specify 'the QR code carries the token, ids, endpoint and expiry, and the settings travel in the token' do
        repository = FactoryBot.create(:valid_repository, creator: user, updater: user)
        namespace = FactoryBot.create(:valid_namespace, creator: user, updater: user)
        qr = nil
        allow(RQRCode::QRCode).to receive(:new).and_wrap_original do |m, text, *args|
          qr = JSON.parse(text)
          m.call(text, *args)
        end

        post "#{task_path}/task_token.json", params: { composition_id: composition.id, repository_id: repository.id, namespace_id: namespace.id }

        expect(qr.keys).to contain_exactly('task_token', 'user_id', 'project_id', 'composition_id', 'endpoint', 'expires_at')
        expect(qr['user_id']).to eq(user.id)
        expect(qr['project_id']).to eq(project.id)
        expect(qr['composition_id']).to eq(composition.id)
        expect(qr['endpoint']).to eq(capture_path)
        expect(TaskToken.decode(qr['task_token'])['attributes']).to eq(
          { 'composition_id' => composition.id, 'repository_id' => repository.id, 'namespace_id' => namespace.id }
        )
      end

      specify 'issue refuses a Composition in another Project' do
        c = Layout::Task.create!(name: 'Other', project: other_project, creator: user, updater: user)
        post "#{task_path}/task_token.json", params: { composition_id: c.id }
        expect(response).to have_http_status(:not_found)
      end

      specify 'invalidate ends the token' do
        post "#{task_path}/task_token.json", params: { composition_id: composition.id }
        delete "#{task_path}/task_token.json"
        expect(response).to have_http_status(:ok)
        get "#{task_path}/task_token.json"
        expect(body['task_token_status']).to be_nil
      end

      specify 'items lists the TaskItems in order' do
        sign_out_token = active_token
        capture(sign_out_token, catalog_number: nil)
        get "#{task_path}/items.json", params: { composition_id: composition.id }
        expect(response).to have_http_status(:ok)
        expect(body.size).to eq(1)
        expect(body.first['depictions'].size).to eq(1)
      end
    end
  end

  context 'initiation (pending token)' do
    specify 'returns a new active token' do
      initiate(pending_token)
      expect(response).to have_http_status(:ok)
      expect(body.keys).to contain_exactly('task_token', 'expires_at')
      expect(Time.iso8601(body['expires_at'])).to be_within(5.seconds).of(Time.current + 2.hours)
      expect(TaskToken.status(user_id: user.id, origin:)['state']).to eq('active')
    end

    specify 'is single use' do
      t = pending_token
      initiate(t)
      initiate(t)
      expect(response).to have_http_status(:unauthorized)
    end

    specify 'refuses mismatched plain-text ids' do
      initiate(pending_token, ids.merge(project_id: other_project.id))
      expect(response).to have_http_status(:unauthorized)
      expect(body.keys).to eq(['errors'])
    end

    specify 'refuses missing plain-text ids' do
      initiate(pending_token, {})
      expect(response).to have_http_status(:unauthorized)
    end

    specify 'an expired QR token is refused' do
      t = pending_token
      travel(2.minutes + 1.second) do
        initiate(t)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'capture (active token)' do
    let!(:token) { active_token }

    specify 'creates a CollectionObject in the Composition' do
      capture(token, text: 'Locality')
      expect(response).to have_http_status(:ok)
      expect(body['result']).to eq('created')
      expect(LayoutItem::TaskItem.where(composition:).count).to eq(1)
    end

    specify 'housekeeping comes from the token, never the session' do
      sign_in(other_user)
      select_project(other_project)
      capture(token)
      co = CollectionObject.find(body['collection_object_id'])
      expect(co.created_by_id).to eq(user.id)
      expect(co.project_id).to eq(project.id)
    end

    specify '422 bodies have no ids' do
      capture(token, collection_object_id: 0)
      expect(response).to have_http_status(:unprocessable_content)
      expect(body.keys).to eq(['errors'])
    end

    specify 'invalidated tokens are refused' do
      TaskToken.invalidate(user_id: user.id, origin:)
      capture(token)
      expect(response).to have_http_status(:unauthorized)
    end

    specify 'the User removed from the Project is refused' do
      ProjectMember.where(user:, project:).delete_all
      capture(token)
      expect(response).to have_http_status(:unauthorized)
    end

    specify 'the Composition gone is refused' do
      composition.destroy!
      capture(token)
      expect(response).to have_http_status(:unauthorized)
    end

    specify 'exceeding the rate is 429 and invalidates the token' do
      stub_const('TaskToken::RATE_LIMIT_PER_MINUTE', 1)
      freeze_time do
        capture(token, image: nil)
        capture(token)
        expect(response).to have_http_status(:too_many_requests)
      end
      travel(2.minutes) do
        capture(token)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    specify 'signing out ends the token' do
      sign_in
      delete '/signout'
      capture(token)
      expect(response).to have_http_status(:unauthorized)
    end

    specify 'selecting a Project ends the token' do
      sign_in
      select_project(other_project)
      capture(token)
      expect(response).to have_http_status(:unauthorized)
    end

    specify 'tokens of other origins for the same User stay live' do
      TaskToken.issue(user_id: user.id, project_id: project.id, origin: 'other_task')
      capture(token)
      expect(response).to have_http_status(:ok)
    end
  end

  context 'transport' do
    specify 'a task_token param in the query string is 400' do
      t = active_token
      post "#{capture_path}?task_token=#{t}", params: ids.merge(image: upload), headers: { 'X-Task-Token' => t }
      expect(response).to have_http_status(:bad_request)
    end

    specify 'a task_token param in the body is 400' do
      t = active_token
      capture(t, task_token: t)
      expect(response).to have_http_status(:bad_request)
    end

    specify 'a token in Authorization is not accepted' do
      t = active_token
      post capture_path, params: ids.merge(image: upload), headers: { 'Authorization' => "Token token=#{t}" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'routes' do
    specify 'a token route refuses a session-only request' do
      sign_in
      select_project
      post capture_path, params: ids.merge(image: upload)
      expect(response).to have_http_status(:unauthorized)
      expect(CollectionObject.count).to eq(0)
    end

    specify 'a token is refused on a session route of the same Task' do
      t = active_token
      get "#{task_path}/items.json", params: { composition_id: composition.id }, headers: { 'X-Task-Token' => t }
      expect(response).to have_http_status(:unauthorized)
    end

    specify 'a token is refused on any other route, even when signed in (never sets Current from a token)' do
      t = active_token
      sign_in(other_user)
      select_project(other_project)
      post '/otus.json', params: { otu: { name: 'Foo' } }, headers: { 'X-Task-Token' => t }
      expect(response).to have_http_status(:unauthorized)
      expect(Otu.count).to eq(0)
    end

    specify 'a token is refused on /api' do
      t = active_token
      get '/api/v1/otus', headers: { 'X-Task-Token' => t }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'lifecycle against Solid Cache', :solid_cache do
    specify 'issue, initiate, capture, invalidate' do
      sign_in
      select_project

      qr = nil
      allow(RQRCode::QRCode).to receive(:new).and_wrap_original do |m, text, *args|
        qr = JSON.parse(text)
        m.call(text, *args)
      end

      post "#{task_path}/task_token.json", params: { composition_id: composition.id }
      expect(SolidCache::Entry.count).to be > 0

      post qr['endpoint'], params: ids.to_json, headers: { 'X-Task-Token' => qr['task_token'], 'CONTENT_TYPE' => 'application/json' }
      expect(response).to have_http_status(:ok)
      t = body['task_token']

      get "#{task_path}/task_token.json"
      expect(body['task_token_status']['state']).to eq('active')

      capture(t)
      expect(response).to have_http_status(:ok)
      expect(body['result']).to eq('created')

      delete "#{task_path}/task_token.json"
      capture(t, image: upload(Spec::Support::Utilities::Files.generate_tiny_random_png))
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
