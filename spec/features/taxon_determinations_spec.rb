require 'spec_helper'

describe 'TaxonDeterminations' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { taxon_determinations_path }
    let(:page_index_name) { 'Taxon Determinations' }
  end

  describe 'GET /taxon_determinations' do
    before {
    sign_in_valid_user_and_select_project 
      visit taxon_determinations_path }
    specify 'an index name is present' do
      expect(page).to have_content('Taxon Determinations')
    end
  end
end



