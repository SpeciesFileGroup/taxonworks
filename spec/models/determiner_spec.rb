require 'rails_helper'

# Determiner is a *Role*, not a person
describe Determiner, type: :model do
  let(:determiner) {Determiner.new}
  context 'associations' do
    context 'has_many' do
      specify 'taxon_determination' do
        expect(determiner).to respond_to(:taxon_determination)
      end

      specify 'determined_otu' do
        expect(determiner).to respond_to(:otu)
      end
    end
  end
end
