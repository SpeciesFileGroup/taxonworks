require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the TaxonNamesHelper. For example:
#
# describe TaxonNamesHelper do
#   describe "string concat" do
#     it "concatenates two strings with spaces" do
#       expect(helper.concat_strings("this", "that")).to eq("this that")
#     end
#   end
# end
describe ContentsHelper, :type => :helper do
  context 'a content needs some helpers' do
    before(:all) {
      @content = FactoryGirl.create(:valid_content)
      @cvt_name = @content.text
    }

    specify '::content_tag' do
      expect(ContentsHelper.content_tag(@content)).to eq(@cvt_name)
    end

    specify '#content_tag' do
      # TODO: Resolve conflict
      skip 'resolution of method \'content_tag\' name conflict'
      expect(content_tag(@content)).to eq(@cvt_name)
    end

    specify '#content_link' do
      expect(content_link(@content)).to have_link(@cvt_name)
    end

    specify "#content_search_form" do
      expect(contents_search_form).to have_button('Show')
      expect(contents_search_form).to have_field('content_id_for_quick_search_form')
    end

  end

end
