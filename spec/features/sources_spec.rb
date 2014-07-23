require 'rails_helper'

describe 'Sources', :type => :feature do

  it_behaves_like 'a_login_required_controller' do 
    let(:index_path) { sources_path }
    let(:page_index_name) { 'Sources' }
  end 

  describe 'GET /sources' do
    before { 
      sign_in_user_and_select_project 
      visit sources_path }
    specify 'an index name is present' do
      expect(page).to have_content('Sources')
    end
  end
end


