require 'rails_helper'

describe CitationsHelper, :type => :helper do
  context 'a citation needs some helpers' do

    let(:citation) { FactoryGirl.create(:valid_citation) }
    let(:citation_object_type) {citation.citation_object_type } 

    after(:all) {
      ProjectsAndUsers.clean_slate
    }

    specify '.citation_tag' do
      expect(CitationsHelper.citation_tag(citation)).to eq(citation_object_type)
    end

    specify '#citation_tag' do
      expect(citation_tag(citation)).to eq(citation_object_type)
    end

    specify '#citation_link' do
      expect(citation_link(citation)).to have_link(citation_object_type)
    end

    specify "#citation_search_form" do
      expect(citations_search_form).to have_button('Show')
      expect(citations_search_form).to have_field('citation_id_for_quick_search_form')
    end

  end
end
