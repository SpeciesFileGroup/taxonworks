require 'spec_helper'

describe "TaxonNameRelationShips" do
  describe "GET /taxon_name_relationships" do
    before { visit taxon_name_relationships_path }
    specify 'an index name is present' do
      expect(page).to have_content('Taxon Name Relationships')
    end
  end
end





