require 'rails_helper'

describe TagsHelper, :type => :helper do
  context 'a tag needs some helpers' do
    let(:tag) {FactoryGirl.create(:valid_tag)}

    specify '.tag_tag' do
      expect(TagsHelper.tag_tag(tag)).to eq(tag.keyword.name)
    end

    specify '#tag_tag' do
      expect(tag_tag(tag)).to eq(tag.keyword.name)
    end

    specify '#tag_link' do
      expect(tag_link(tag)).to have_link(tag.keyword.name)
    end

    specify "#tag_search_form" do
      expect(tags_search_form).to have_button('Show')
      expect(tags_search_form).to have_field('tag_id_for_quick_search_form')
    end

  end
end
