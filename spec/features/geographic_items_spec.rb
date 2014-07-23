require 'rails_helper'

describe 'GeographicItems', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { geographic_items_path }
    let(:page_index_name) { 'Geographic Items' }
  end  
 
  describe 'GET /geographic_items' do
    before { 
      sign_in_user_and_select_project 
      visit geographic_items_path }
    specify 'an index name is present' do
      expect(page).to have_content('Geographic Items')
    end
  end
end





