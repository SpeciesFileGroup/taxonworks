require 'spec_helper'

describe TaxonDetermination do

  let(:taxon_determination) {TaxonDetermination.new}

  context 'associations' do
    context 'belongs_to' do
      specify 'otu' do
        expect(taxon_determination).to respond_to(:otu)
      end

      specify 'biological_collection_object' do
        expect(taxon_determination).to respond_to(:biological_collection_object)
      end
    end

    context 'has_on' do
      specify 'determiner' do
        expect(taxon_determination).to respond_to(:determiner)
      end
    end
  end

end
