require 'spec_helper'

describe OtuContent::Text do
  let(:text) { OtuContent::Text.new }

  # foreign key relationships
  context "reflections / foreign keys" do
    context "belongs to" do
      specify "topic" do
        expect(text).to respond_to(:topic)
      end
    end

    context "validation" do
      specify "text must exist in text"
      specify "there is an otu"
      specify "there is a topic"
    end

  end

end

