require 'spec_helper'

describe "ControlledVocabularyTerms" do
  describe "GET /controlled_vocabulary_terms" do
    before { visit controlled_vocabulary_terms_path }
    specify 'an index name is present' do
      expect(page).to have_content('Controlled Vocabulary Terms')
    end
  end
end


