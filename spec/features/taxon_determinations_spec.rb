require 'rails_helper'

describe 'TaxonDeterminations', :type => :feature do
  let(:page_index_name) { 'Taxon determinations' }

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { taxon_determinations_path }
  end

  describe 'GET /taxon_determinations' do
    before {
    sign_in_user_and_select_project 
      visit taxon_determinations_path }
    specify 'an index name is present' do
      expect(page).to have_content(page_index_name)
    end
  end
end



