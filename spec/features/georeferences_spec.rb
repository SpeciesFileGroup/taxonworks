require 'spec_helper'

describe 'Georeferences', base_class: Georeference do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /georeferences' do
    before {
      sign_in_valid_user_and_select_project 
      visit georeferences_path }
    specify 'an index name is present' do
      expect(page).to have_content('Georeferences')
    end
  end
end






