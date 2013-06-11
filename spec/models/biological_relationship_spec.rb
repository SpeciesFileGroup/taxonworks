require 'spec_helper'

describe BiologicalRelationship do

  let(:biological_relationship) { BiologicalRelationship.new }

  context "validation" do
    context "requires" do
      before do
        biological_relationship.save
      end

      # Is this true? We could generate a name based on properties at that stage.
      specify "name" do
        expect(biological_relationship.errors.include?(:name)).to be_true
      end
    end
  end

  context "foreign keys / relationships" do

    context "has many" do
      specify "biological properties" do
        expect(biological_relationship).to respond_to(:biological_properties)
      end

      # The biological properties pertinent to the domain (subject)
      specify "domain properties" do
        expect(biological_relationship).to respond_to(:domain_properties)
      end

      # The biological properties pertinent to the range (object)
      specify "range properties" do
        expect(biological_relationship).to respond_to(:range_properties)
      end

      specify "biological_associations" do 
        expect(biological_relationship).to respond_to(:biological_associations)
      end
    end

  end

end
