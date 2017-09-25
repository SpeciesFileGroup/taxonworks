require 'rails_helper'
# require 'workbench/navigation_helper'

describe CitationsHelper, :type => :helper do
  context 'a citation needs some helpers' do
    let(:otu) {FactoryGirl.create(:valid_otu, name: 'Tigerbearcat') } 
    let(:source) {FactoryGirl.create(:valid_source_bibtex, author: 'Smith, J.', year: '1929') } 
    let(:citation) { FactoryGirl.create(:valid_citation, citation_object: otu, source: source) }
    let(:link_text) { 'Otu: ' + helper.otu_tag(otu) + ' in Smith, 1929'  }

    specify '.citation_tag format' do
      expect( helper.citation_tag(citation)).to eq(link_text)
    end

    specify '#citation_link' do
      expect(helper.citation_link(citation)).to match(link_text)
    end

    specify "#citation_search_form" do
      expect(helper.citations_search_form).to_not have_button('Edit')
      expect(helper.citations_search_form).to have_field('citation_id_for_quick_search_form')
    end
  end
end
