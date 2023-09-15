require 'rails_helper'

describe User, type: :model do

  let(:user) { User.new(password: 'password',
                        password_confirmation: 'password',
                        email: 'user_model@example.com',
                        name: 'Bob'
                       ) }

  subject { user }

  context 'associations' do
    context 'has_many' do
      specify 'projects' do
        expect(user.projects << Project.new).to be_truthy
      end

      specify 'pinboard_items' do
        expect(user.pinboard_items << PinboardItem.new).to be_truthy
      end
    end
  end

  context 'stored preferences' do
    specify '#hub_favorites' do
      expect(user.hub_favorites).to eq({})
    end

    specify '#preferences' do
      user
      expect(user.preferences).to eq({})
    end

    specify '#footprints' do
      expect(user.footprints).to eq({})
    end

    context '#hub_tab_order' do
      specify 'is an array' do
        expect(user.hub_tab_order).to eq([])
      end

      specify 'is set to DEFAULT_HUB_TAB_ORDER after_create' do
        expect(user.save!).to be_truthy
        expect(user.hub_tab_order).to eq(DEFAULT_HUB_TAB_ORDER)
      end
    end
  end

  context 'authorization' do
    context 'when just a user' do
      specify '#is_administrator? is false' do
        expect(user.is_administrator?).to be(false)
      end

      specify '#is_project_administrator? is false' do
        expect(user.is_project_administrator?).to be(false)
      end

      specify '#is_super_user?' do
        expect(user.is_superuser?).to be(false)
      end
    end

    context 'when administator' do
      before { user.is_administrator = true }
      specify '#is superuser?' do
        expect(user.is_superuser?).to be true
      end
    end

    context 'when a project administrator' do
      before {
        ProjectMember.create(project_id: Current.project_id, user: user, is_project_administrator: true)
      }

      specify '#is_superuser(project)?' do
        expect(user.is_superuser?(Project.find(Current.project_id))).to be true
      end

      specify '#administered_projects' do
        expect(user.administered_projects).to contain_exactly(Project.find(Current.project_id))
      end

      specify '#administers_projects?' do
        expect(user.administers_projects?).to be true
      end

    end
  end

  context 'with password, password confirmation, name, and email' do
    it { is_expected.to be_valid }
  end

  context 'with password, password confirmation, name < 2 characters, and email' do
    before { user.password = user.name = 'a' }
    it { is_expected.to be_invalid }
  end

  context 'when password is empty' do
    before { user.password = user.password_confirmation = '' }
    it { is_expected.to be_invalid }
  end

  context 'when password confirmation doesn\'t match' do
    before { user.password_confirmation = 'mismatch' }
    it { is_expected.to be_invalid }
  end

  context 'when password is too short' do
    before { user.password = user.password_confirmation = 'a' * 5 }
    it { is_expected.to be_invalid }
  end

  context 'when email is empty' do
    before { user.email = '' }
    it { is_expected.to be_invalid }
  end

  context 'when email doesn\'t match expected format' do
    before { user.email = 'a b@c.d' }
    it { is_expected.to be_invalid }
  end

  describe 'saved user' do
    before { user.save }
    context 'password is not validated on .update() when neither password and password_confirmation are provided' do
      before { user.update(email: 'abc@def.com') }
      it { is_expected.to be_valid }
      specify 'without errors' do
        expect(user.errors.count).to eq(0)
      end
    end

    context 'password is validated on .update() when password is provided' do
      before { user.update(password: 'Abcd123!') }
      it { is_expected.not_to be_valid }
    end

    context 'password is validated on .update() when password is provided' do
      before { user.update(password_confirmation: 'Abcd123!') }
      it { is_expected.not_to be_valid }
    end
  end

  context 'new users' do
    before {
      user.self_created = true
      user.save
    }

    specify 'if self_created = true creator is self after save' do
      expect(user.creator).to eq(user)
    end

    specify 'if self_created = true updater is self after save' do
      expect(user.updater).to eq(user)
    end
  end

  describe 'remember token' do
    before { user.save }
    it(:remember_token) { is_expected.not_to be_blank }
  end

  describe 'password reset token' do
    it 'is nil on a newly created user' do
      expect(user.password_reset_token).to be_nil
    end

    include_examples 'random_token_methods' do
      let(:token_name) { :password_reset }
    end
  end

  describe 'API access token' do
    it 'is nil on a newly created user' do
      expect(user.api_access_token).to be_nil
    end

    describe '#generate_api_access_token' do
      it 'returns a secure random string generated from Utilities::RandomToken.generate' do
        value = Utilities::RandomToken.generate
        allow(Utilities::RandomToken).to receive(:generate).and_return(value)
        expect(user.generate_api_access_token).to eq(value)
      end

      it 'stores the token in api_access_token field' do
        token = user.generate_api_access_token
        expect(user.api_access_token).to eq(token)
      end
    end
  end

  context 'user activity summaries' do
    before {
      user.save!
      4.times { (FactoryBot.create(:valid_otu, creator: user, updater: user)) }
      @last_otu = FactoryBot.create(:valid_otu, creator: user, updater: user)
    }

    specify '#update_last_seen_at' do
      user.update_last_seen_at
      expect(user.last_seen_at).to be_truthy
    end

    # specify '.last Otu created by me' do
    #   expect(user.last_otu_created).to eq @last_otu
    # end

    specify '#total_objects(Otu)' do
      expect(user.total_objects(Otu)).to eq 5
    end

    specify "#total_objects2('otus')" do # klass_string expects plural
      expect(user.total_objects2('otus')).to eq 5
    end
  end

  context 'footprints' do
    before {
      user.save
    }
    let(:otu) { Otu.create(name: 'for footprints testing') }
    let(:object_route) { "/otus/#{otu.to_param}" }

    context 'add_recently_visited_to_footprint' do

      specify 'with a route and no recent object' do
        user.add_recently_visited_to_footprint('/otus/')
        expect(user.footprints).to eq('recently_visited' => [{'/otus/' => {}}])
      end

      specify 'with a route and a recent object' do
        user.add_recently_visited_to_footprint(object_route, otu)
        expect(user.footprints).to eq('recently_visited' => [{object_route => {'object_type' => 'Otu',
                                                                               'object_id' => otu.id}}])
      end

      specify 'with the same route and recent object > 1x' do
        user.add_recently_visited_to_footprint(object_route, otu)
        user.add_recently_visited_to_footprint(object_route, otu)
        user.add_recently_visited_to_footprint(object_route, otu)

        expect(user.footprints).to eq('recently_visited' => [{object_route => {'object_type' => 'Otu',
                                                                               'object_id' => otu.id}}])
      end

      specify 'current limit is 10 items' do
        (0..25).each do |i|
          user.add_recently_visited_to_footprint("/otus/#{i}")
        end
        expect(user.footprints['recently_visited'].count).to eq(20)
      end

    end
  end

  context 'scopes' do
    let(:p) { Project.create(name: 'Stubbed for project member test') }
    let(:u1) { User.first.id }
    let!(:u2) { User.create(name: 'Jones', email: 'abc@example.com', self_created: true, password: 'acdadewsr1A') }

    specify '.not_in_project' do
      expect(User.not_in_project(1).to_a).to include(u2)
    end

    specify '.in_project' do
      expect(User.in_project(1).to_a).to include(u1)
    end
  end

  context 'concerns' do
    it_behaves_like 'data_attributes'
    it_behaves_like 'notable'
    # it_behaves_like 'random_token_fields'
  end

  context 'user tranfers' do
    let(:user) { FactoryBot.create(:valid_user) }
    let(:target_user) { FactoryBot.create(:valid_user) }
    let(:another_user) { FactoryBot.create(:valid_user) }

    describe '#transfer_housekeeping' do
      before do
        4.times { FactoryBot.create(:valid_protonym, creator: user, updater: user) }
        3.times { FactoryBot.create(:valid_geographic_area, creator: target_user, updater: user) }
        5.times { FactoryBot.create(:valid_otu, creator: another_user, updater: another_user, updated_at: 1.week.ago) }
        user.transfer_housekeeping(target_user)
      end
  
      it 'removes user from housekeeping data' do
        expect(TaxonName.where(created_by_id: user.id).or(TaxonName.where(updated_by_id: user.id))).to be_empty
        expect(GeographicArea.where(created_by_id: user.id).or(GeographicArea.where(updated_by_id: user.id))).to be_empty
      end
  
      it 'assigns user to housekeeping data' do
        expect(TaxonName.where(created_by_id: target_user.id).or(TaxonName.where(updated_by_id: target_user.id)).count).to eq(4)
        expect(GeographicArea.where(created_by_id: target_user.id).or(GeographicArea.where(updated_by_id: target_user.id)).count).to eq(3)
      end
  
      it 'alters involved users only' do
        expect(Otu.where(created_by_id: another_user.id).or(Otu.where(updated_by_id: another_user.id)).count).to eq(5)
      end

      it 'does not set updated at to current time' do
        expect(Otu.where(updated_at: 1.day.ago..)).to be_empty
      end
    end

    describe '#transfer_projects_membership' do
      let(:common_project) { FactoryBot.create(:valid_project) }
      let(:user_project) { FactoryBot.create(:valid_project) }
      let(:target_user_project) { FactoryBot.create(:valid_project) }
      let(:another_user_project) { FactoryBot.create(:valid_project) }
      let!(:existing_membership) { ProjectMember.create!(project: common_project, user: target_user, is_project_administrator: false).reload }

      before do
        ProjectMember.create!(project: common_project, user: user, is_project_administrator: true)

        ProjectMember.create!(project: user_project, user: user, is_project_administrator: true)
        ProjectMember.create!(project: target_user_project, user: target_user, is_project_administrator: true)

        ProjectMember.create!(project: another_user_project, user: another_user, is_project_administrator: true)

        user.transfer_projects_membership(target_user)
      end

      it 'assigns all user projects to target user' do
        expect(target_user.projects.count).to eq(3)
      end

      it 'retains memberships already existing in target user' do
        members_attributes = common_project.project_members.map(&:attributes)
        expect(members_attributes).to contain_exactly(existing_membership.attributes)
      end

      it 'removes user membership from all projects' do
        expect(user.projects).to be_empty
      end

      it 'alters involved users only' do
        expect(another_user.projects.count).to eq(1)
      end
    end
  end
end
