require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the CitationsHelper. For example:
#
# describe CitationsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe CitationsHelper, :type => :helper do
  context 'a citation needs some helpers' do
    before(:all) {
      $user_id  = 1; $project_id = 1
      @citation = FactoryGirl.create(:valid_citation)
      @cvt_name = @citation.citation_object_type
    }

    specify '::citation_tag' do
      expect(CitationsHelper.citation_tag(@citation)).to eq(@cvt_name)
    end

    specify '#citation_tag' do
      expect(citation_tag(@citation)).to eq(@cvt_name)
    end

    specify '#citation_link' do
      expect(citation_link(@citation)).to have_link(@cvt_name)
    end

    specify "#citation_search_form" do
      expect(citations_search_form).to have_button('Show')
      expect(citations_search_form).to have_field('citation_id_for_quick_search_form')
    end

  end
end
