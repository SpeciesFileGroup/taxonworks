require 'rails_helper'

describe 'Tags', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { tags_path }
    let(:page_index_name) { 'Tags' }
  end

  describe 'GET /tags' do
    before {
      sign_in_user_and_select_project
      visit tags_path
    }
    
    specify 'an index name is present' do
      expect(page).to have_content('Tags')
    end
    
  end

   pending 'clicking a tag link anywhere renders the tagged object in <some> view'

end


