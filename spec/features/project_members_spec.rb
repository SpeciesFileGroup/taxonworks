require 'rails_helper'

# TODO: fix this.

describe 'Project Members', :type => :feature do
  
# it_behaves_like 'a_superuser_login_required_and_project_selected_controller' do 
#   let(:index_path) { notes_path }
#   let(:page_index_name) { 'Project Members' }
# end 

  describe 'GET /Project Members' do
    before { 
      sign_in_administrator
      visit project_members_path }
    specify 'an index name is present' do
      expect(page).to have_content('Project Members')
    end
  end
end

