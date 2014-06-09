require 'spec_helper'

describe 'TaxonNameRelationships', base_class: TaxonNameRelationship do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /taxon_name_relationships' do
    before { visit taxon_name_relationships_path }
    specify 'an index name is present' do
      expect(page).to have_content('Taxon Name Relationships')
    end
  end
end





