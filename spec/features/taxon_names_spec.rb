require 'spec_helper'

describe "TaxonNames" do
  describe "GET /taxon_names" do
    before { visit taxon_names_path }
    specify 'an index name is present' do
      expect(page).to have_content('Taxon Names')
    end
  end
end






