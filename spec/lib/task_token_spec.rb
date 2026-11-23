require 'rails_helper'

describe TaskToken, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:origin) { 'quick_mobile_material_task' }
  let(:user) { FactoryBot.create(:valid_user) }
  let(:project) { FactoryBot.create(:valid_project, without_root_taxon_name: true) }
  let(:attributes) { { 'composition_id' => 3 } }

  let(:issued) { TaskToken.issue(user_id: user.id, project_id: project.id, origin:, attributes:) }

  # Initiation and activation as the concern performs it.
  def activate(token, lifetime: 2.hours)
    r = TaskToken.verify(token, origin:)
    return r unless r.stage == :initiation
    TaskToken.activate(r.payload, lifetime:)
  end

  after { Rails.cache.clear }

  context '.issue' do
    specify 'returns a token and its expiry, 2 minutes out' do
      freeze_time do
        expect(issued.token).to be_a(String)
        expect(issued.expires_at).to eq(Time.current + TaskToken::PENDING_LIFETIME)
      end
    end

    specify 'writes a pending origin entry' do
      issued
      expect(TaskToken.status(user_id: user.id, origin:)['state']).to eq('pending')
    end

    specify 'creates the user nonce when absent' do
      expect(Rails.cache.read(TaskToken::Store.nonce_key(user.id))).to be_nil
      issued
      expect(Rails.cache.read(TaskToken::Store.nonce_key(user.id))).to be_present
    end

    specify 'reuses an existing user nonce' do
      issued
      n = Rails.cache.read(TaskToken::Store.nonce_key(user.id))
      TaskToken.issue(user_id: user.id, project_id: project.id, origin: 'other_task')
      expect(Rails.cache.read(TaskToken::Store.nonce_key(user.id))).to eq(n)
    end

    specify 'origin is required' do
      expect { TaskToken.issue(user_id: user.id, project_id: project.id, origin: nil) }.to raise_error(ArgumentError)
    end
  end

  context '.decode' do
    specify 'round trips the payload' do
      p = TaskToken.decode(issued.token)
      expect(p['user_id']).to eq(user.id)
      expect(p['project_id']).to eq(project.id)
      expect(p['origin']).to eq(origin)
      expect(p['jti']).to be_present
      expect(p['nonce']).to be_present
      expect(p['expires_at']).to be_present
      expect(p['attributes']).to eq(attributes)
    end

    specify 'the token is encrypted, the payload is not readable' do
      expect(issued.token).not_to include(origin)
      expect(Base64.decode64(issued.token.split('--').first)).not_to include(origin)
    end

    specify 'nil when tampered' do
      t = issued.token.dup
      t[5] = (t[5] == 'A' ? 'B' : 'A')
      expect(TaskToken.decode(t)).to be_nil
    end

    specify 'nil when garbage' do
      expect(TaskToken.decode('not a token')).to be_nil
      expect(TaskToken.decode(nil)).to be_nil
    end

    specify 'nil when expired' do
      t = issued.token
      travel(TaskToken::PENDING_LIFETIME + 1.second) do
        expect(TaskToken.decode(t)).to be_nil
      end
    end

    specify 'nil for a message encrypted for another purpose' do
      t = TaskToken::Codec.encryptor.encrypt_and_sign({ 'jti' => 'x' }, purpose: :other)
      expect(TaskToken.decode(t)).to be_nil
    end
  end

  context '.verify' do
    specify 'a pending token is at the initiation stage' do
      r = TaskToken.verify(issued.token, origin:)
      expect(r.status).to eq(:ok)
      expect(r.stage).to eq(:initiation)
    end

    specify 'rejects another origin' do
      expect(TaskToken.verify(issued.token, origin: 'other_task').status).to eq(:unauthorized)
    end

    specify 'rejects a missing token' do
      expect(TaskToken.verify(nil, origin:).status).to eq(:unauthorized)
    end

    specify 'rejects a stale jti (a newer QR was issued for the origin)' do
      t = issued.token
      TaskToken.issue(user_id: user.id, project_id: project.id, origin:)
      expect(TaskToken.verify(t, origin:).status).to eq(:unauthorized)
    end

    specify 'rejects when the origin entry is gone (fails closed on eviction)' do
      t = issued.token
      Rails.cache.delete(TaskToken::Store.origin_key(user.id, origin))
      expect(TaskToken.verify(t, origin:).status).to eq(:unauthorized)
    end

    specify 'rejects when the user nonce is gone' do
      t = issued.token
      Rails.cache.delete(TaskToken::Store.nonce_key(user.id))
      expect(TaskToken.verify(t, origin:).status).to eq(:unauthorized)
    end

    specify 'rejects when the user nonce was recreated (evicted then recreated)' do
      t = issued.token
      Rails.cache.delete(TaskToken::Store.nonce_key(user.id))
      TaskToken.issue(user_id: user.id, project_id: project.id, origin: 'other_task')
      expect(TaskToken.verify(t, origin:).status).to eq(:unauthorized)
    end

    specify 'rejects an expired token' do
      t = issued.token
      travel(TaskToken::PENDING_LIFETIME + 1.second) do
        expect(TaskToken.verify(t, origin:).status).to eq(:unauthorized)
      end
    end
  end

  context '.activate (single use)' do
    specify 'returns an active token with the lifetime' do
      freeze_time do
        a = activate(issued.token, lifetime: 1.hour)
        expect(a.token).to be_present
        expect(a.expires_at).to eq(Time.current + 1.hour)
        expect(TaskToken.status(user_id: user.id, origin:)['state']).to eq('active')
      end
    end

    specify 'the active token is at the capture stage' do
      a = activate(issued.token)
      r = TaskToken.verify(a.token, origin:)
      expect(r.status).to eq(:ok)
      expect(r.stage).to eq(:capture)
    end

    specify 'carries user, project, origin and attributes forward with a new jti' do
      a = activate(issued.token)
      before = TaskToken.decode(issued.token)
      after = TaskToken.decode(a.token)
      expect(after.slice('user_id', 'project_id', 'origin', 'nonce', 'attributes')).to eq(before.slice('user_id', 'project_id', 'origin', 'nonce', 'attributes'))
      expect(after['jti']).not_to eq(before['jti'])
    end

    specify 'the 2 minute token is dead after activation' do
      t = issued.token
      activate(t)
      expect(TaskToken.verify(t, origin:).status).to eq(:unauthorized)
    end

    specify 'a second activation of the same payload is refused' do
      r = TaskToken.verify(issued.token, origin:)
      expect(TaskToken.activate(r.payload, lifetime: 2.hours)).to be_present
      expect(TaskToken.activate(r.payload, lifetime: 2.hours)).to be_nil
    end

    specify 'extension is one time, the active token is not extended by use' do
      a = activate(issued.token, lifetime: 1.hour)
      travel(30.minutes) { TaskToken.verify(a.token, origin:) }
      travel(1.hour + 1.second) do
        expect(TaskToken.verify(a.token, origin:).status).to eq(:unauthorized)
      end
    end

    specify 'an active token can not be activated again (no sliding)' do
      a = activate(issued.token)
      r = TaskToken.verify(a.token, origin:)
      expect(r.stage).to eq(:capture)
      expect(TaskToken.activate(r.payload, lifetime: 2.hours)).to be_nil
    end
  end

  context '.invalidate' do
    specify 'kills the token for the origin' do
      a = activate(issued.token)
      TaskToken.invalidate(user_id: user.id, origin:)
      expect(TaskToken.verify(a.token, origin:).status).to eq(:unauthorized)
      expect(TaskToken.status(user_id: user.id, origin:)).to be_nil
    end

    specify 'leaves the User\'s other origins live' do
      other = TaskToken.issue(user_id: user.id, project_id: project.id, origin: 'other_task')
      TaskToken.invalidate(user_id: user.id, origin:)
      expect(TaskToken.verify(other.token, origin: 'other_task').status).to eq(:ok)
    end
  end

  context '.invalidate_user' do
    specify 'kills every token of the User, across origins' do
      a = activate(issued.token)
      other = TaskToken.issue(user_id: user.id, project_id: project.id, origin: 'other_task')
      TaskToken.invalidate_user(user.id)
      expect(TaskToken.verify(a.token, origin:).status).to eq(:unauthorized)
      expect(TaskToken.verify(other.token, origin: 'other_task').status).to eq(:unauthorized)
    end

    specify 'does not touch other Users' do
      u2 = FactoryBot.create(:valid_user)
      t2 = TaskToken.issue(user_id: u2.id, project_id: project.id, origin:)
      TaskToken.invalidate_user(user.id)
      expect(TaskToken.verify(t2.token, origin:).status).to eq(:ok)
    end
  end

  context 'throttles' do
    specify 'total requests default to 500 per minute of lifetime' do
      expect(TaskToken.total_request_limit(2.hours)).to eq(60_000)
    end

    specify 'exceeding the per-minute rate invalidates the token (429)' do
      a = activate(issued.token)
      stub_const('TaskToken::RATE_LIMIT_PER_MINUTE', 3)
      freeze_time do
        3.times { expect(TaskToken.verify(a.token, origin:).status).to eq(:ok) }
        expect(TaskToken.verify(a.token, origin:).status).to eq(:too_many_requests)
      end
      expect(TaskToken.status(user_id: user.id, origin:)).to be_nil
      travel(2.minutes) do
        expect(TaskToken.verify(a.token, origin:).status).to eq(:unauthorized)
      end
    end

    specify 'the per-minute rate resets in the next minute' do
      a = activate(issued.token)
      stub_const('TaskToken::RATE_LIMIT_PER_MINUTE', 2)
      travel_to(Time.current.beginning_of_minute) do
        2.times { TaskToken.verify(a.token, origin:) }
      end
      travel_to(Time.current.beginning_of_minute + 1.minute) do
        expect(TaskToken.verify(a.token, origin:).status).to eq(:ok)
      end
    end

    specify 'exceeding the lifetime total invalidates the token (429)' do
      stub_const('TaskToken::TOTAL_REQUESTS_PER_MINUTE_OF_LIFETIME', 1)
      a = activate(issued.token, lifetime: 3.minutes) # total 3
      3.times { |i| travel(i.minutes) { expect(TaskToken.verify(a.token, origin:).status).to eq(:ok) } }
      travel(2.minutes + 30.seconds) do
        expect(TaskToken.verify(a.token, origin:).status).to eq(:too_many_requests)
      end
      expect(TaskToken.status(user_id: user.id, origin:)).to be_nil
    end

    specify 'a nil increment (cache failure) fails closed' do
      a = activate(issued.token)
      allow(Rails.cache).to receive(:increment).and_return(nil)
      expect(TaskToken.verify(a.token, origin:).status).to eq(:unauthorized)
    end
  end

  context '.live?' do
    let(:composition) { FactoryBot.create(:valid_layout_task, project:) }
    let(:payload) { { 'user_id' => user.id, 'project_id' => project.id, 'attributes' => { 'composition_id' => composition.id } } }

    before { FactoryBot.create(:valid_project_member, user:, project:) }

    specify 'true when User, membership and Composition check out' do
      expect(TaskToken.live?(payload)).to be_truthy
    end

    specify 'false when the User is gone' do
      expect(TaskToken.live?(payload.merge('user_id' => 0))).to be_falsey
    end

    specify 'false when the User is flagged for password reset' do
      user.update_column(:is_flagged_for_password_reset, true)
      expect(TaskToken.live?(payload)).to be_falsey
    end

    specify 'false when the User is no longer a member of the Project' do
      ProjectMember.where(user:, project:).delete_all
      expect(TaskToken.live?(payload)).to be_falsey
    end

    specify 'false when the Composition is in another Project' do
      p2 = FactoryBot.create(:valid_project, without_root_taxon_name: true)
      composition.update_column(:project_id, p2.id)
      expect(TaskToken.live?(payload)).to be_falsey
    end

    specify 'false when the Composition is gone' do
      expect(TaskToken.live?(payload.merge('attributes' => { 'composition_id' => 0 }))).to be_falsey
    end
  end

  context '.ids_match?' do
    let(:payload) { { 'user_id' => 1, 'project_id' => 2, 'attributes' => { 'composition_id' => 3 } } }

    specify 'true when the plain ids agree' do
      expect(TaskToken.ids_match?(payload, { 'user_id' => '1', 'project_id' => '2', 'composition_id' => '3' })).to be_truthy
    end

    specify 'false when any disagrees' do
      expect(TaskToken.ids_match?(payload, { 'user_id' => '1', 'project_id' => '9', 'composition_id' => '3' })).to be_falsey
      expect(TaskToken.ids_match?(payload, { 'user_id' => '1', 'project_id' => '2', 'composition_id' => '9' })).to be_falsey
    end

    specify 'false when any is missing' do
      expect(TaskToken.ids_match?(payload, { 'user_id' => '1', 'project_id' => '2' })).to be_falsey
    end
  end

  context 'concurrent activation against Solid Cache', :solid_cache do
    specify 'exactly one request activates' do
      r = TaskToken.verify(issued.token, origin:)
      payload = r.payload

      results = 5.times.map do
        Thread.new do
          SolidCache::Record.connection_pool.with_connection do
            ApplicationRecord.connection_pool.with_connection { TaskToken.activate(payload, lifetime: 2.hours) }
          end
        end
      end.map(&:value)

      expect(results.compact.size).to eq(1)
    end
  end
end
