require 'rails_helper'

describe 'TaxonNames' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { taxon_names_path }
    let(:page_index_name) { 'Taxon Names' }
  end  
 
  describe 'GET /taxon_names' do
    before {
    sign_in_user_and_select_project 
      visit taxon_names_path }
    specify 'an index name is present' do
      expect(page).to have_content('Taxon Names')
    end
  end
end






