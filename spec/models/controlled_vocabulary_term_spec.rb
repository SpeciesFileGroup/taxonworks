require 'spec_helper'

describe ControlledVocabularyTerm do
  let(:controlled_vocabulary_term) { ControlledVocabularyTerm.new }

  context "validation" do 
    specify "it must have a name"
    specify "it must have a definition"
  end

end

