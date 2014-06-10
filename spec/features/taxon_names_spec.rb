require 'spec_helper'

describe 'TaxonNames', TaxonName do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /taxon_names' do
    before {
    sign_in_valid_user_and_select_project 
      visit taxon_names_path }
    specify 'an index name is present' do
      expect(page).to have_content('Taxon Names')
    end
  end
end






