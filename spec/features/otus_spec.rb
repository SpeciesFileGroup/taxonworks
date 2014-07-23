require 'rails_helper'

# :base_class is defined by us, it is accessible as example.metadata[:base_class].  It's used 
describe 'Otus', :type => :feature do 
 
  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { otus_path }
    let(:page_index_name) { 'Otus' }
  end

  describe 'GET /otus' do
    before { 
      sign_in_user_and_select_project
      visit otus_path 
    }
    specify 'an index name is present' do
      expect(page).to have_content('Otus')
    end
  end


end
