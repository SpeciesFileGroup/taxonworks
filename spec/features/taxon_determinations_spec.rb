require 'spec_helper'

describe "TaxonDeterminations" do
  describe "GET /taxon_determinations" do
    before { visit taxon_determinations_path }
    specify 'an index name is present' do
      expect(page).to have_content('Taxon Determinations')
    end
  end
end



