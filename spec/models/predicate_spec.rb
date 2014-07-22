require 'rails_helper'

describe Predicate do
  let(:predicate) { Predicate.new }

  # foreign key relationships
  context "reflections / foreign keys" do
    context "has many" do
      specify "attributes"
      specify "subjects"
    end
  end

  context "validation" do
    specify "can be used for attributes only"
  end
end
