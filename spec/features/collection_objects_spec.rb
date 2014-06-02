require 'spec_helper'

describe "CollectionObjects" do
  describe "GET /collection_objects" do
    before { visit collection_objects_path }
    specify 'an index name is present' do
      expect(page).to have_content('Collection Objects')
    end
  end
end

