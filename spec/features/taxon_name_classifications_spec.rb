require 'spec_helper'

describe 'TaxonNameClassifications', base_class: TaxonNameClassification do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /taxon_name_classifications' do
    before { visit taxon_name_classifications_path }
    specify 'an index name is present' do
      expect(page).to have_content('Taxon Name Classifications')
    end
  end
end




