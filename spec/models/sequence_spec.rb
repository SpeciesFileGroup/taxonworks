require 'rails_helper'

RSpec.describe Sequence, type: :model do
  let(:sequence) {Sequence.new}

  context 'validation' do
    context 'fails when not given' do
      specify 'sequence' do
        sequence.valid?
        expect(sequence.errors.include?(:sequence)).to be_truthy
      end

      specify 'sequence_type' do
        sequence.valid?
        expect(sequence.errors.include?(:sequence_type)).to be_truthy
      end

      specify 'valid sequence_type' do
        sequence = FactoryGirl.create(:valid_sequence)
        sequence.sequence_type = "INVALID TYPE"
        expect(sequence.valid?).to be_falsey
      end
    end

    context 'passes when given' do
      specify 'sequence and valid sequence_type' do
        sequence = FactoryGirl.create(:valid_sequence)
        expect(sequence.valid?).to be_truthy
      end
    end
  end
end
