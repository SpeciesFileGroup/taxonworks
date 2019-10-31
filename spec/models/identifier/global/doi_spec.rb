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

      specify '10.12345/TaxonWorks-\d{45}' do
        id.identifier = '10.12345/TaxonWorks-' + Faker::Number.number(digits: 10).to_s
        expect(id.valid?).to be_truthy
      end

      specify '10.1234.5678/TaxonWorks-\d{45}' do
        id.identifier = '10.' + Faker::Number.decimal(l_digits: 4, r_digits: 4).to_s + '/TaxonWorks-' + Faker::Number.number(digits: 10).to_s
        expect(id.valid?).to be_truthy
      end

      # Technically any Unicode is good unicode, even periods at the end
      specify '10.1234.5678/TaxonWorks-123.' do
        id.identifier = '10.1234.5678/TaxonWorks-123.'
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
