require 'rails_helper'

describe Identifier::Global::Lccn, type: :model, group: :identifiers do
  context 'LCCN' do
    let(:id) { Identifier::Global::Lccn.new(identifier_object:  FactoryBot.build(:valid_source)) }

    context '#identifier is validly formatted' do

      specify 'empty' do
        # identifier is empty
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('can\'t be blank')
      end

      specify 'any old word' do
        phrase = Faker::Lorem.unique.word
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed LCCN.")
      end

      context 'LCCN Structure B (2001- )' do

        specify '2003-06485 (too few digits)' do
          phrase = '2003-06485'
          id.identifier = phrase
          expect(id.valid?).to be_falsey
          expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed LCCN.")
        end

        specify 'ISSN 0317-8479' do
          phrase = 'ISSN 0317-8479'
          id.identifier = phrase
          expect(id.valid?).to be_falsey
          expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed LCCN.")
        end

        specify '2003-0648507 (too many digits)' do
          phrase = '2003-0648507'
          id.identifier = phrase
          expect(id.valid?).to be_falsey
          expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed LCCN.")
        end

        specify '2001-459440' do
          phrase = '2001-459440'
          id.identifier = phrase
          expect(id.valid?).to be_truthy
        end
      end

      context 'LCCN Structure A (1898-2000)' do

        specify '68-004897' do
          phrase = '68-004897'
          id.identifier = phrase
          expect(id.valid?).to be_truthy
        end

        specify '96046612' do
          phrase  = '96046612'
          id.identifier = phrase
          expect(id.valid?).to be_truthy
        end

        specify '98046612' do
          phrase = '98046612'
          id.identifier = phrase
          expect(id.valid?).to be_truthy
        end

        specify '98002999' do
          phrase = '98002999'
          id.identifier = phrase
          expect(id.valid?).to be_truthy
        end

        specify '99046612' do
          phrase = '99046612'
          id.identifier = phrase
          expect(id.valid?).to be_truthy
        end

        specify '99005999' do
          phrase = '99005999'
          id.identifier = phrase
          expect(id.valid?).to be_truthy
        end

        specify '00007999 ' do
          phrase = '00007999'
          id.identifier = phrase
          expect(id.valid?).to be_truthy
        end

        specify '00049000 ' do
          phrase = '00049000'
          id.identifier = phrase
          expect(id.valid?).to be_truthy
        end

      end
    end
  end
end
