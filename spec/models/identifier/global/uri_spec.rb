require 'rails_helper'

describe Identifier::Global::Uri, type: :model, group: :identifiers do

  context 'URI' do
    let(:id) { Identifier::Global::Uri.new(identifier_object: FactoryBot.build(:valid_otu)) }

    context '#identifier is validly formatted' do

      specify 'empty' do
        # identifier is empty
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('can\'t be blank')
      end

      specify 'any old word' do
        id.identifier = Faker::Lorem.unique.word
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('No URI detected.')
      end

      specify 'does UDP work?' do
        id.identifier = 'udp://localhost.org'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('UDP is not in the URI schemes list.')
      end

      specify 'ftp::aaaa' do
        id.identifier = 'ftp::aaaa'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('Badly formed URI ftp::aaaa detected.')
      end

      specify 'ftp://TaxonWorks.Org and https://TaxonWorks.Org' do
        id.identifier = 'ftp://TaxonWorks.Org and https://TaxonWorks.Org'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('More than a single URI present.')
      end

      specify 'Other stuff and FTP://TaxonWorks.Org' do
        id.identifier = 'Other stuff and FTP://TaxonWorks.Org'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('More than a single URI present.')
      end

      specify 'PICKLES://TaxonWorks.Org' do
        id.identifier = 'PICKLES://TaxonWorks.Org'
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('PICKLES is not in the URI schemes list.')
      end

      specify 'ftp://TaxonWorks.Org' do
        id.identifier = 'ftp://TaxonWorks.Org'
        expect(id.valid?).to be_truthy
      end

    end

  end
end
