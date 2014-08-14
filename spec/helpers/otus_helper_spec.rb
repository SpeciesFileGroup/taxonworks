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
describe OtusHelper, :type => :helper do
  context 'an otu needs some helpers' do
    before(:all) {
      @otu = FactoryGirl.create(:valid_otu, name: 'voluptas')
    }

    specify '::otu_tag' do
      expect(OtusHelper.otu_tag(@otu)).to eq('voluptas')
    end

    specify '#otu_tag' do
      expect(@otu.otu_tag(@otu)).to eq('Adidae')
    end

    specify '#otu_link' do
      expect(@otu.otu_link(@otu)).to eq('Adidae')
    end

    specify "#otu_search_form" do
      expect(@otu.otus_search_form).to respond_to(:otus_search_form)
    end

  end

end
