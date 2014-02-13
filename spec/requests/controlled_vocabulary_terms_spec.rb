require 'spec_helper'

describe "ControlledVocabularyTerms" do
  describe "GET /controlled_vocabulary_terms" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get controlled_vocabulary_terms_path
      response.status.should be(200)
    end
  end
end
