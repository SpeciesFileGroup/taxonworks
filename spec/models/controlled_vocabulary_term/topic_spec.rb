require 'spec_helper'

describe ControlledVocabularyTerm::Topic do
  let(:topic) { ControlledVocabularyTerm::Topic.new }

  # foreign key relationships
  context "reflections / foreign keys" do
    context "has many" do
    end
  end

  context "validation" do
    specify "can be used for content"
    specify "can be used for citations"
    specify "can not be used for tags"
  end

end

