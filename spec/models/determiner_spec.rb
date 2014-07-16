require 'rails_helper'

describe Determiner do
  let(:determiner) {Determiner.new}

  context 'associations' do
    context 'has_many' do
      specify 'taxon_determinations' do
        expect(determiner).to respond_to(:taxon_determinations)
      end

      specify 'determined_otus' do
        expect(determiner).to respond_to(:taxon_determinations)
      end

      specify 'determined_biological_collection_objects' do
        skip
      end
    end
  end

end
