require 'spec_helper'

describe BiologicalAssociationsGraph do

  let(:biological_associations_graph) { BiologicalAssociationsGraph.new }

  context "validation" do

    before do
      biological_associations_graph.valid?
    end

    context "required fields" do
      specify "name" do
        expect(biological_associations_graph).to respond_to(:name)
        expect(biological_associations_graph.errors.include?(:name)).to be_true 
      end
    end 
  
  end

  context "foreign keys / relationships" do
    context "has many" do
      specify "biological associations" do
        expect(biological_associations_graph).to respond_to(:biological_associations)
      end
    end
  end

end


