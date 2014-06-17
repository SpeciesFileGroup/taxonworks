require 'spec_helper'

describe 'Tags' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { tags_path }
    let(:page_index_name) { 'Tags' }
  end

  describe 'GET /tags' do
    before { 
      sign_in_valid_user_and_select_project   
      visit tags_path 
    }
    specify 'an index name is present' do
      expect(page).to have_content('Tags')
    end
  end

end


