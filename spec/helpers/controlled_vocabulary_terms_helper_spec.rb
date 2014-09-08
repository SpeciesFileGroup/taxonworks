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
describe ControlledVocabularyTermsHelper, :type => :helper do
  context 'a controlled_vocabulary_term needs some helpers' do
    before(:all) {
      $user_id                    = 1; $project_id = 1
      @controlled_vocabulary_term = FactoryGirl.create(:valid_controlled_vocabulary_term)
      @cvt_name                   = @controlled_vocabulary_term.name
    }

    specify '::controlled_vocabulary_term_tag' do
      expect(ControlledVocabularyTermsHelper.controlled_vocabulary_term_tag(@controlled_vocabulary_term)).to eq(@cvt_name)
    end

    specify '#controlled_vocabulary_term_tag' do
      expect(controlled_vocabulary_term_tag(@controlled_vocabulary_term)).to eq(@cvt_name)
    end

    specify '#controlled_vocabulary_term_link' do
      expect(controlled_vocabulary_term_link(@controlled_vocabulary_term)).to have_link(@cvt_name)
    end

    specify "#controlled_vocabulary_term_search_form" do
      expect(controlled_vocabulary_terms_search_form).to have_button('Show')
      expect(controlled_vocabulary_terms_search_form).to have_field('controlled_vocabulary_term_id_for_quick_search_form')
    end

  end

end
