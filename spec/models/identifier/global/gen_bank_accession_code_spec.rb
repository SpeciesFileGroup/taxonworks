require 'rails_helper'

describe Identifier::Global::GenBankAccessionCode, type: :model, group: :identifiers do
  context 'GenBankAccessionCode' do
    let(:id) { Identifier::Global::GenBankAccessionCode.new(identifier_object: FactoryBot.create(:valid_sequence)) }

    context '#identifier is invalid format' do
      specify 'empty' do
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("can't be blank")
      end

      specify 'too few characters' do
        id.identifier = 'A1'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('invalid format')
      end

      specify 'too many characters' do
        id.identifier = 'ABC1234567'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('invalid format')
      end

      specify 'lowercase 6 character version' do
        id.identifier = 'a12345'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('invalid format')
      end

      specify 'lowercase 8 character version' do
        id.identifier = 'ab123456'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('invalid format')
      end

      context 'valid identifier surrounded by other characters' do
        specify '6 character version' do
          id.identifier = 'AB1234567'
          expect(id.valid?).to be_falsey
          expect(id.errors.messages[:identifier][0]).to eq('invalid format')
        end

        specify '8 character version' do
          id.identifier = 'AAB1234567'
          expect(id.valid?).to be_falsey
          expect(id.errors.messages[:identifier][0]).to eq('invalid format')
        end
      end
    end

    context '#identifier is valid format' do
      specify '6 character version' do
        id.identifier = 'A12345'
        expect(id.valid?).to be_truthy
      end

      specify '8 character version' do
        id.identifier = 'AB123456'
        expect(id.valid?).to be_truthy
      end
    end
  end
end
