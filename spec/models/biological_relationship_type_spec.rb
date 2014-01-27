require 'spec_helper'

describe BiologicalRelationshipType do
  let(:biological_relationship_type) { FactoryGirl.build(:biological_relationship_type) }

  context "validation" do 
    context "requires" do
      before do
        biological_relationship_type.valid?
      end

      specify "type" do
        expect(biological_relationship_type.errors.include?(:type)).to be_true
      end

      specify "biological_property" do
        expect(biological_relationship_type.errors.include?(:biological_property)).to be_true
      end
 
     specify "biological_relationship" do
        expect(biological_relationship_type.errors.include?(:biological_relationship)).to be_true
      end
    end
  end
end

