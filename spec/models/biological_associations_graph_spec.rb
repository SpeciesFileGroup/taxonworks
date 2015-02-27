require 'rails_helper'

describe BiologicalAssociationsGraph, :type => :model do

  let(:biological_associations_graph) { FactoryGirl.build(:biological_associations_graph) } 

  # There are no hard validations.  Name is optional (re virtual graphs that have to be cited).

  context "associations" do
    context 'belongs_to' do
      specify "source" do
        expect(biological_associations_graph).to respond_to(:source)
      end
    end

    context "has many" do
      specify "biological_associations" do
        expect(biological_associations_graph).to respond_to(:biological_associations)
      end

      specify "biological_associations_biological_associations_graphs" do
        expect(biological_associations_graph).to respond_to(:biological_associations_biological_associations_graphs)
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'citable'
  end

end


