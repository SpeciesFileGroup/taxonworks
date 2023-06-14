require 'rails_helper'

describe Identifier::Global::Lsid, type: :model, group: :identifier do
  context 'LSID' do
    let(:id) { Identifier::Global::Lsid.new(identifier_object: FactoryBot.build(:valid_otu)) }

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
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is not a valid LSID.")
      end

      specify 'urn:lsid:orthoptera.speciesfile.org:Taxonname:1' do
        phrase        = 'urn:lsid:orthoptera.speciesfile.org:Taxonname:1'
        id.identifier = phrase
        expect(id.valid?).to be_truthy
      end

      specify 'ISBN-10: 978-0-59652-068-7' do
        phrase        = 'ISBN-10: 978-0-59652-068-7'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is not a valid LSID.")
      end

      specify 'urn:lsid:orthoptera.speciesfile.org:Taxonname:1:revision=44' do
        phrase        = 'urn:lsid:orthoptera.speciesfile.org:Taxonname:1:revision=44'
        id.identifier = phrase
        expect(id.valid?).to be_truthy
      end

    end
  end
end
