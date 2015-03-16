require 'rails_helper'

describe 'RangedLotCategories', :type => :feature do
  let(:page_index_name) { 'Ranged lot categories' }
  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { ranged_lot_categories_path }
  end

  describe 'GET /ranged_lot_categories' do
    before {
    sign_in_user_and_select_project 
      visit ranged_lot_categories_path }
    specify 'an index name is present' do
      expect(page).to have_content(page_index_name)
    end
  end
end
