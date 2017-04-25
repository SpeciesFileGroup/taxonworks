require 'rails_helper'

describe ContentsHelper, type: :helper do
  context 'a content needs some helpers' do
    let!(:content) {FactoryGirl.create(:valid_content) }
    let(:target) {helper.content_tag(:span, helper.object_tag(content.topic) + ' - ' + helper.object_tag(content.otu))}

    specify '#taxon_works_content_tag' do
      expect(helper.taxon_works_content_tag(content)).to eq(target)
    end

    specify '.taxon_works_content_tag' do
      expect(helper.taxon_works_content_tag(content)).to eq(target)
    end

    specify '#content_link' do
      expect(helper.content_link(content)).to match(target)
    end

    specify "#content_search_form" do
      expect(helper.contents_search_form).to have_button('Show')
      expect(helper.contents_search_form).to have_field('content_id_for_quick_search_form')
    end

  end

end
