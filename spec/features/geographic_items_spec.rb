require 'spec_helper'

describe 'GeographicItems', base_class: GeographicItem do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /geographic_items' do
    before { 
      sign_in_valid_user_and_select_project 
      visit geographic_items_path }
    specify 'an index name is present' do
      expect(page).to have_content('Geographic Items')
    end
  end
end





