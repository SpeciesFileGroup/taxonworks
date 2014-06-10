require 'spec_helper'

describe 'PublicContents', base_class: PublicContent do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /public_contents' do
    before {
      sign_in_valid_user_and_select_project 
      visit public_contents_path }
    specify 'an index name is present' do
      expect(page).to have_content('Public Contents')
    end
  end
end
