require 'spec_helper'

describe BiologicalAssociationsGraph do

  let(:biological_associations_graph) { BiologicalAssociationsGraph.new }

  context 'validation' do
    pending 'require some edges to be post-save validly_published'
  end

  context 'foreign keys / relationships' do
    context 'has many' do
      specify 'biological associations' do
        expect(biological_associations_graph).to respond_to(:biological_associations)
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'citable'
  end

end


