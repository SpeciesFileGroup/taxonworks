require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the TagsHelper. For example:
#
# describe TagsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe TagsHelper, :type => :helper do
  context 'a tag needs some helpers' do
    before(:all) {
      $user_id  = 1; $project_id = 1
      @tag      = FactoryGirl.create(:valid_tag)
      @cvt_name = @tag.keyword.name
    }

    specify '::tag_tag' do
      expect(TagsHelper.tag_tag(@tag)).to eq(@cvt_name)
    end

    specify '#tag_tag' do
      expect(tag_tag(@tag)).to eq(@cvt_name)
    end

    specify '#tag_link' do
      expect(tag_link(@tag)).to have_link(@cvt_name)
    end

    specify "#tag_search_form" do
      expect(tags_search_form).to have_button('Show')
      expect(tags_search_form).to have_field('tag_id_for_quick_search_form')
    end

  end
end
