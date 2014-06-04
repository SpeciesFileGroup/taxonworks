require 'spec_helper'

describe "TaxonNameClassifications" do
  describe "GET /taxon_name_classifications" do
    before { visit taxon_name_classifications_path }
    specify 'an index name is present' do
      expect(page).to have_content('Listing taxon_name_classifications')
    end
  end
end




