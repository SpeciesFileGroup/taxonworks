require 'spec_helper'

describe Topic do
  let(:topic) { Topic.new }

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

