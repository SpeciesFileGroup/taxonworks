require 'spec_helper'

describe ControlledVocabularyTerm::Keyword do
  let(:topic) { ControlledVocabularyTerm::Keyword.new }

  context "associations" do
  end

  context "validation" do
    specify "can be used for tags"
    specify "can not be used for citations"
  end

end

