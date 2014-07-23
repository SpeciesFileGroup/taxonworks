require 'rails_helper'

describe 'TaxonNameClassifications', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { taxon_name_classifications_path }
    let(:page_index_name) { 'Taxon Name Classifications' }
  end 
 
  describe 'GET /taxon_name_classifications' do
    before {
    sign_in_user_and_select_project 
      visit taxon_name_classifications_path }
    specify 'an index name is present' do
      expect(page).to have_content('Taxon Name Classifications')
    end
  end
end




