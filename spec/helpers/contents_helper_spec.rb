require 'rails_helper'

describe ContentsHelper, :type => :helper do
  context 'a content needs some helpers' do
    let(:content) {FactoryGirl.create(:valid_content) }
    let(:tag_string) {content.text}

    specify '#taxon_works_content_tag' do
      expect(helper.taxon_works_content_tag(content)).to eq(tag_string)
    end

    specify '.taxon_works_content_tag' do
      # TODO: Resolve conflict
      expect(taxon_works_content_tag(content)).to eq(tag_string)
    end

    specify '#content_link' do
      expect(content_link(content)).to have_link(tag_string)
    end

    specify "#content_search_form" do
      expect(contents_search_form).to have_button('Show')
      expect(contents_search_form).to have_field('content_id_for_quick_search_form')
    end

  end

end
