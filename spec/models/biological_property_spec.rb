require 'spec_helper'

# A class representing a single biological property. Examples: "male", "adult", "host", "parasite".

describe BiologicalProperty do

  let(:biological_property) { BiologicalProperty.new }

  context "validation" do 
    context "requires" do
      before do
        biological_property.save
      end

      specify "name" do
        expect(biological_property.errors.include?(:name)).to be_true
      end

      specify "definition" do
        expect(biological_property.errors.include?(:name)).to be_true
      end

    end


  end
end
