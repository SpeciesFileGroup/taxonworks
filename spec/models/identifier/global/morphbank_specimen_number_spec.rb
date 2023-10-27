require 'rails_helper'

describe Identifier::Global::MorphbankSpecimenNumber, type: :model, group: :identifiers do
  context 'MorphbankSpecimenNumber' do
    let(:id) { Identifier::Global::MorphbankSpecimenNumber.new(identifier_object: FactoryBot.build(:valid_specimen)) }

    context '#identifier is invalid format' do
      specify 'empty' do
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("can't be blank")
      end

      specify 'non-numbers' do
        id.identifier = 'asdfSJFoi-ASD_sfs'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('invalid format, only numbers allowed')
      end

      specify 'mixed' do
        id.identifier = '2asdfS234JFoi-ASD_sfs333'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('invalid format, only numbers allowed')
      end
    end

    context '#identifier is valid format' do
      specify 'numbers' do
        id.identifier = '123456'
        expect(id.valid?).to be_truthy
      end
    end
  end
end
