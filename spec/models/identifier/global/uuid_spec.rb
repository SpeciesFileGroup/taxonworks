require 'rails_helper'

describe Identifier::Global::Uuid, type: :model, group: :identifiers do
  context 'UUID' do
    let(:id) { Identifier::Global::Uuid.new(identifier_object: FactoryBot.build(:valid_specimen)) }

    context '#identifier is validly formatted' do

      specify 'empty' do
        # identifier is empty
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('can\'t be blank')
      end

      specify 'any old word' do
        phrase        = Faker::Lorem.unique.word
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("#{phrase} is not a valid UUID.")
      end

      specify 'ca761232ed42DEADBEEF00aa0057b223' do
        phrase        = 'ca761232ed42DEADBEEF00aa0057b223'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("#{phrase} is not a valid UUID.")
      end

      specify 'ca761232-ed42-DEAD-BEEF-00aa0057b223' do
        id.identifier = 'ca761232-ed42-DEAD-BEEF-00aa0057b223'
        expect(id.valid?).to be_truthy
      end

    end
  end
end
