require 'spec_helper'

describe Role::Determiner do
  let(:determiner) {Role::Determiner.new}

  context 'associations' do
    context 'has_many' do
      specify 'taxon_determinations' do
        expect(determiner).to respond_to(:taxon_determinations)
      end

      specify 'determined_otus' do
        expect(determiner).to respond_to(:taxon_determinations)
      end

      specify 'determined_biological_collection_objects' do
        pending
      end
    end
  end

end
