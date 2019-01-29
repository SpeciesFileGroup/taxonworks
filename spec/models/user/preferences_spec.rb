require 'rails_helper'

describe User, type: :model, group: [:user] do

  let(:user) { User.new(
    password: 'password',
    password_confirmation: 'password',
    email: 'user_model@example.com',
    name: 'Bob'
  ) }

  context 'user.yml' do 
    context 'accessors exist for' do
      User::BASE_PREFERENCES.keys.each do |k|
        specify "#{k}" do
          expect(user.respond_to?(k)).to be_truthy
        end
      end
    end
  end

  context 'hashed keys' do
    specify '.hash_preferences' do
      expect(User.hash_preferences).to include(layout: {})
    end

    specify '.array_preferences' do
      expect(User.array_preferences).to include(default_hub_tab_order: [])
    end

    specify '.key_value_preferences' do
      expect(User.key_value_preferences).to include(:disable_chime, :items_per_list_page) # etc.
    end
  end

  specify 'filled preferences are not over-written' do
    user.disable_chime = true
    user.save!
    expect(user.disable_chime).to eq(true)
  end

  specify 'unfilled preferences are filled' do
    user.disable_chime = true
    user.save!
    expect(user.items_per_list_page).to eq(20)
  end

  specify '#reset_preferences' do
    user.reset_preferences
    expect(user.preferences).to eq(User::BASE_PREFERENCES)
  end

  context 'with one layout set' do
    before do
      user.layout = { foo: {'firstid' => 1, 'secondid' => 2}}
      user.save!
    end

    specify 'updating another layout' do
      user.layout = {bar: {'second_id' => 1}}
      expect(user.layout.keys).to contain_exactly('foo', 'bar')
    end
  end

end
