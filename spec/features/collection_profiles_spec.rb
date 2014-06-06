require 'spec_helper'

describe "CollectionProfiles" do
  describe "GET /collection_profiles" do
    before { visit collection_profiles_path }
    specify 'an index name is present' do
      expect(page).to have_content('Collection Profiles')
    end
  end
end
