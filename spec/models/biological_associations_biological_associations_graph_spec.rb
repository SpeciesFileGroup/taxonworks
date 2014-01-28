require 'spec_helper'

describe BiologicalAssociationsBiologicalAssociationsGraph do

  let(:biological_associations_biological_associations_graph) { FactoryGirl.build(:biological_associations_biological_associations_graph) } 


  context "validation" do
    context "requires" do
      before(:each) {
        biological_associations_biological_associations_graph.valid?
      }      

      specify "biological_associations_graph" do
        expect(biological_associations_biological_associations_graph.errors.include?(:biological_associations_graph)).to be_true
      end

      specify "biological_association" do
        expect(biological_associations_biological_associations_graph.errors.include?(:biological_association)).to be_true
      end
    end
  end


end
