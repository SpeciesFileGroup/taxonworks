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
describe TaxonNamesHelper, :type => :helper do
  context 'a taxon_name needs some helpers' do
    before(:all) {
      $user_id    = 1; $project_id = 1
      @taxon_name = FactoryGirl.create(:valid_taxon_name)
    }

    specify '#taxon_name_for_select' do
      expect(taxon_name_for_select(@taxon_name)).to eq('Adidae')
    end

    specify '#parent_taxon_name_for_select' do
      expect(parent_taxon_name_for_select(@taxon_name)).to eq('Root')
    end

    specify '::taxon_name_tag' do
      expect(TaxonNamesHelper.taxon_name_tag(@taxon_name)).to eq('Adidae')
    end

    specify '#taxon_name_tag' do
      expect(taxon_name_tag(@taxon_name)).to eq('Adidae')
    end

    specify '#taxon_name_link' do
      expect(taxon_name_link(@taxon_name)).to have_link('Adidae')
    end

    specify "#taxon_name_rank_select_tag" do
      expect(taxon_name_rank_select_tag(taxon_name: @taxon_name, code: :iczn)).to have_select('taxon_name_rank_class')
    end

  end

end
