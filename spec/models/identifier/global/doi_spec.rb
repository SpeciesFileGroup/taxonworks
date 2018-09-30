require 'rails_helper'

describe Identifier::Global::Doi, type: :model, group: :identifiers do

  context 'DOI.Org' do
    let(:id) { FactoryBot.build(:identifier_global_doi) }

    context '#identifier is validly formatted' do
      specify 'empty' do
        # identifier is empty
        expect(id.valid?).to be_falsey
      end

      specify 'any old word' do
        id.identifier = Faker::Lorem.word
        expect(id.valid?).to be_falsey
      end

      specify '10.12345/TaxonWorks-' do
        id.identifier = '10.12345/TaxonWorks-' + Faker::Number.number(45)
        expect(id.valid?).to be_truthy
      end

      specify '10.1234.5678/TaxonWorks-' do
        id.identifier = '10.' + Faker::Number.decimal(4, 4) + '/TaxonWorks-' + Faker::Number.number(45)
        expect(id.valid?).to be_truthy
      end
    end

    context 'prefixes' do
      specify 'with doi:' do
        id.identifier = 'doi:10.2105/AJPH.2009.160184'
        expect(id.valid?).to be_truthy
        expect(id.identifier).to eq('10.2105/AJPH.2009.160184')
      end

      specify 'with http:' do
        id.identifier = 'http://dx.doi.org/10.2105/AJPH.2009.160184'
        expect(id.valid?).to be_truthy
        expect(id.identifier).to eq('10.2105/AJPH.2009.160184')
      end

      specify 'with https:' do
        id.identifier = 'https://doi.org/10.2105/AJPH.2009.160184'
        expect(id.valid?).to be_truthy
        expect(id.identifier).to eq('10.2105/AJPH.2009.160184')
      end
    end

    specify 'restoring URL from identifier' do
      id.identifier = 'http://dx.doi.org/10.2105/AJPH.2009.160184'
      expect(id.valid?).to be_truthy
      expect(Identifier::Global::Doi.preface_doi(id.identifier)).to eq('https://doi.org/10.2105/AJPH.2009.160184')
    end
  end
end
