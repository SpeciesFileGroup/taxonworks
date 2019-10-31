require 'rails_helper'

describe Identifier::Global::Orcid, type: :model, group: :identifiers do
  context 'Orcid' do
    let(:id) { FactoryBot.build(:identifier_global_orcid) }

    context '#identifier is validly formatted' do

      specify 'empty' do
        # identifier is empty
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('can\'t be blank')
      end

      specify 'any old word' do
        phrase = Faker::Lorem.word
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed ORCID ID.")
      end

      specify 'http://orcid.org/00100-03002-13825-00497' do
        phrase = 'http://orcid.org/00100-03002-13825-00497'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed ORCID ID.")
      end

      specify 'http://orcid.org/0000-0002-1825-0096' do
        phrase = 'http://orcid.org/0000-0002-1825-0096'
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' has bad check digit.")
      end

      specify 'http://orcid.org/0000-0002-1825-0097' do
        phrase = 'http://orcid.org/0000-0002-1825-0097'
        id.identifier = phrase
        expect(id.valid?).to be_truthy
      end

      specify 'orcid.org/0000-0002-1825-0097' do
        phrase = 'http://orcid.org/0000-0002-1825-0097'
        id.identifier = phrase
        expect(id.valid?).to be_truthy
      end
    end
  end
end
