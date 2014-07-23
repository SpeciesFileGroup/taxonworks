require 'rails_helper'

describe 'TaggedSectionKeywords', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { tagged_section_keywords_path }
    let(:page_index_name) { 'Tagged Section Keywords' }
  end

  describe 'GET /tagged_section_keywords' do
    before { 
     sign_in_user_and_select_project 
      visit tagged_section_keywords_path }
    specify 'an index name is present' do
      expect(page).to have_content('Tagged Section Keywords')
    end
  end
end
