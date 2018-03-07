require 'rails_helper'

describe ContentsHelper, type: :helper do
  context 'a content needs some helpers' do
    let(:name) {'My topic'}
    let(:topic) { FactoryBot.create(:valid_topic, name: name)}
    let!(:content) {FactoryBot.create(:valid_content, topic: topic) }

    specify '#taxon_works_content_tag' do
      expect(helper.taxon_works_content_tag(content)).to match(name)
    end

    specify '.taxon_works_content_tag' do
      expect(helper.taxon_works_content_tag(content)).to match(name)
    end

    specify '#content_link' do
      expect(helper.content_link(content)).to match(name)
    end

    specify '#content_search_form' do
      expect(helper.contents_search_form).to have_field('content_id_for_quick_search_form')
    end

  end

end
