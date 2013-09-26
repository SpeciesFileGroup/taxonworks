require 'spec_helper'

describe BiologicalAssociation do

  let(:biological_association) { BiologicalAssociation.new }

  context "validation" do
    context "requires" do
      before do
        biological_association.save
      end

      # Is this true? We could generate a name based on properties at that stage.
      specify "object_id" do
        expect(biological_association.errors.include?(:biological_association_object_id)).to be_true
      end

      specify "subject_id" do
        expect(biological_association.errors.include?(:biological_association_subject_id)).to be_true
      end
 
      specify "subject_type" do
        expect(biological_association.errors.include?(:subject_type)).to be_true
      end
 
      specify "object_type" do
        expect(biological_association.errors.include?(:object_type)).to be_true
      end

      specify "biological_relationship_id" do
        expect(biological_association.errors.include?(:object_type)).to be_true
      end

    end
  end

  context "foreign keys / relationships" do
    context "belongs to" do
      specify "biological relationship" do
        expect(biological_association).to respond_to(:biological_relationship)
      end
    end
    

  end

end

