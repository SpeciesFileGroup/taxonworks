require 'rails_helper'

describe TagsHelper, type:  :helper do
  context 'a tag needs some helpers' do
    let(:tag) {FactoryBot.create(:valid_tag)}

    let(:tag_string) { tag.keyword.name }

    specify '#tag_tag' do
      expect(helper.tag_tag(tag)).to match(tag_string)
    end

    specify '#tag_link' do
      expect(helper.tag_link(tag)).to match(tag_string)
    end

  end
end
