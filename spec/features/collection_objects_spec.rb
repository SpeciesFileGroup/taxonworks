require 'spec_helper'

describe 'CollectionObjects' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /collection_objects' do
    before { visit collection_objects_path }
    specify 'an index name is present' do
      expect(page).to have_content('Collection Objects')
    end
  end
end

