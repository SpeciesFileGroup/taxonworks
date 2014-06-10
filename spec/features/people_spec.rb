require 'spec_helper'

describe 'People', base_class: Person do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /people' do
    before { 
      sign_in_valid_user_and_select_project 
      visit people_path }
    specify 'an index name is present' do
      expect(page).to have_content('People')
    end
  end
end

