require 'rails_helper'

describe BiologicalRelationship, :type => :model do

  let(:biological_relationship) { FactoryGirl.build(:biological_relationship) } 

  context "validation" do
    context "requires" do
      before(:each) {
        biological_relationship.valid?
      }      

      specify "name" do
        expect(biological_relationship.errors.include?(:name)).to be_truthy
      end
    end
  end

  context "associations" do
    context "has many" do
      specify "biological_relationship_types" do
        expect(biological_relationship).to respond_to(:biological_relationship_types)
      end

      specify "biological_associations" do
        expect(biological_relationship).to respond_to(:biological_associations)
      end

      specify "biological_properties" do 
        expect(biological_relationship).to respond_to(:biological_properties)
      end
    end
  end
end
