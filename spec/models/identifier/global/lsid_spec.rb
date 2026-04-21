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
        expect(id.errors.messages[:identifier][0]).to include('is not a valid LSID')
      end

      specify 'urn:lsid:orthoptera.speciesfile.org:Taxonname:1:revision=44' do
        phrase        = 'urn:lsid:orthoptera.speciesfile.org:Taxonname:1:revision=44'
        id.identifier = phrase
        expect(id.valid?).to be_truthy
      end

      specify 'URN:LSID:orthoptera.speciesfile.org:Taxonname:1 (uppercase)' do
        phrase        = 'URN:LSID:orthoptera.speciesfile.org:Taxonname:1'
        id.identifier = phrase
        expect(id.valid?).to be_truthy
      end

      # leading and trailing whitespace is removed by nilify_blanks (globally)
      specify 'with internal whitespace' do
        phrase        = 'urn:lsid:orthoptera.speciesfile.org:Taxon name:1'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to include('contains whitespace')
      end

      specify 'missing authority' do
        phrase        = 'urn:lsid::Taxonname:1'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is not a valid LSID.")
      end

      specify 'missing namespace' do
        phrase        = 'urn:lsid:orthoptera.speciesfile.org::1'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is not a valid LSID.")
      end

      specify 'missing object' do
        phrase        = 'urn:lsid:orthoptera.speciesfile.org:Taxonname:'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is not a valid LSID.")
      end

      specify 'too few parts' do
        phrase        = 'urn:lsid:orthoptera.speciesfile.org:Taxonname'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is not a valid LSID.")
      end

      specify 'too many parts' do
        phrase        = 'urn:lsid:orthoptera.speciesfile.org:Taxonname:1:rev:extra'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is not a valid LSID.")
      end

      specify 'wrong prefix' do
        phrase        = 'uri:lsid:orthoptera.speciesfile.org:Taxonname:1'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is not a valid LSID.")
      end

      specify 'wrong second part' do
        phrase        = 'urn:isbn:orthoptera.speciesfile.org:Taxonname:1'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is not a valid LSID.")
      end

    end
  end
end
