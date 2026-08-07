require 'rails_helper'

describe Identifier::Global::Issn, type:  :model, group: :identifier do
  context 'ISSN' do
    let(:id) { Identifier::Global::Issn.new(identifier_object: FactoryBot.build(:valid_source)) }

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
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed ISSN.")
      end

      specify 'ISBN 0317-8471' do
        phrase        = 'ISBN 0317-8471'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed ISSN.")
      end

      specify 'ISSN 0317-847' do
        phrase        = 'ISSN 0317-847'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed ISSN.")
      end

      specify 'ISSN 0317-8479' do
        phrase        = 'ISSN 0317-8479'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' has bad check digit.")
      end

      specify 'ISSN 0317-8471' do
        phrase        = '0317-8471'
        id.identifier = phrase
        expect(id.valid?).to be_truthy
      end

      specify 'ISSN 1050-124X' do
        phrase        = 'ISSN 1050-124X'
        id.identifier = phrase
        expect(id.valid?).to be_truthy
      end

      specify 'ISSN 1234-5679' do
        phrase        = 'ISSN 1234-5679'
        id.identifier = phrase
        expect(id.valid?).to be_truthy
      end

    end
  end
end
