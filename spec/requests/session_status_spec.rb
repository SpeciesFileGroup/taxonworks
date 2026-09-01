require 'rails_helper'

describe 'SessionsController#status', type: :request do

  let(:password) { 'abcD123!' }

  let!(:administrator) {
    User.create!(name: 'Pat the Administrator', email: 'administrator@example.com',
                 password:, password_confirmation: password, is_administrator: true, self_created: true)
  }

  let!(:user) {
    User.create!(name: 'Pat User', email: 'user@example.com',
                 password:, password_confirmation: password, self_created: true)
  }

  let!(:project) {
    Project.create!(name: 'My Project', creator: administrator, updater: administrator, without_root_taxon_name: true)
  }

  let(:body) { JSON.parse(response.body) }

  def sign_in
    post '/sessions', params: {session: {email: user.email, password:}}
  end

  def select_project
    project.project_members.create!(creator: administrator, updater: administrator, user:)
    get "/projects/#{project.id}/select"
  end

  context 'when signed out' do
    before { get '/session_status.json' }

    it 'renders 200 rather than redirecting or raising' do
      expect(response).to have_http_status(:ok)
    end

    it 'reports no user and no project' do
      expect(body).to eq({'signed_in' => false, 'project_selected' => false})
    end
  end

  context 'when signed in without a project selected' do
    before do
      sign_in
      get '/session_status.json'
    end

    it 'reports the user but no project' do
      expect(body).to eq({'signed_in' => true, 'project_selected' => false})
    end
  end

  context 'when signed in with a project selected' do
    before do
      sign_in
      select_project
      get '/session_status.json'
    end

    it 'reports both' do
      expect(body).to eq({'signed_in' => true, 'project_selected' => true})
    end

    # This is what makes the endpoint a keepalive: merely reading the session
    # commits it, so the cookie is re-issued with its expiry pushed to
    # `Time.now + expire_after` (see config/initializers/session_store.rb).
    it 'reissues the session cookie with a refreshed expiry' do
      cookie = Array(response.headers['Set-Cookie']).join("\n")[/_TaxonWorks_session=[^\n]*/]

      expect(cookie).to be_present

      expires_at = Time.parse(cookie[/expires=([^;]+)/, 1])
      expected_at = Time.now.utc + Rails.application.config.session_options[:expire_after]

      expect(expires_at).to be_within(1.minute).of(expected_at)
    end
  end

  context 'user activity tracking' do
    before do
      sign_in
      user.update_columns(last_seen_at: nil, time_active: 0)
      get '/session_status.json'
    end

    # See Tracking::UserTime: heartbeats every few minutes would otherwise
    # accumulate time_active as though the user were continuously working.
    it 'does not count the heartbeat as activity' do
      expect(user.reload.last_seen_at).to be_nil
    end
  end
end
