require 'spec_helper'

describe 'TaggedSectionKeywords', base_class: TaggedSectionKeyword do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /tagged_section_keywords' do
    before { 
     sign_in_valid_user_and_select_project 
      visit tagged_section_keywords_path }
    specify 'an index name is present' do
      expect(page).to have_content('Tagged Section Keywords')
    end
  end
end
