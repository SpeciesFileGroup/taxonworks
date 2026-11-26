require 'rails_helper'

describe Identifier::Global::Doi, type: :model, group: :identifiers do

  context 'DOI.Org' do
    let(:id) { Identifier::Global::Doi.new(identifier_object: FactoryBot.create(:valid_otu)) }

    context '#identifier is validly formatted' do
      specify 'empty' do
        # identifier is empty
        expect(id.valid?).to be_falsey
      end

      specify 'any old word' do
        id.identifier = Faker::Lorem.unique.word
        expect(id.valid?).to be_falsey
      end

      specify '10.12345/TaxonWorks-\d{45}' do
        id.identifier = '10.12345/TaxonWorks-' + Faker::Number.unique.number(digits: 10).to_s
        expect(id.valid?).to be_truthy
      end

      specify '10.1234.5678/TaxonWorks-\d{45}' do
        id.identifier = '10.' + Faker::Number.unique.decimal(l_digits: 4, r_digits: 4).to_s + '/TaxonWorks-' + Faker::Number.number(digits: 10).to_s
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
        id.valid? # trigger refactor
        expect(id.identifier).to eq('10.2105/AJPH.2009.160184')
      end

      specify 'with http:' do
        id.identifier = 'http://dx.doi.org/10.2105/AJPH.2009.160184'
        id.valid? # trigger refactor
        expect(id.identifier).to eq('10.2105/AJPH.2009.160184')
      end

      specify 'with https:' do
        id.identifier = 'https://doi.org/10.2105/AJPH.2009.160184'
        id.valid? # trigger refactor
        expect(id.identifier).to eq('10.2105/AJPH.2009.160184')
      end

      specify 'in brackets' do
        id.identifier = '(doi:10.2105/AJPH.2009.160184)'
        expect(id.valid?).to be_truthy
        expect(id.identifier).to eq('10.2105/AJPH.2009.160184')
      end

      specify 'with doi: and a space' do
        id.identifier = 'doi: 10.2105/AJPH.2009.160184'
        expect(id.valid?).to be_truthy
        expect(id.identifier).to eq('10.2105/AJPH.2009.160184')
      end
    end

    context '.normalize' do
      {
        '10.2105/AJPH.2009.160184' => '10.2105/AJPH.2009.160184',
        ' doi:10.2105/AJPH.2009.160184 ' => '10.2105/AJPH.2009.160184',
        'DOI: 10.2105/AJPH.2009.160184' => '10.2105/AJPH.2009.160184',
        'https://dx.doi.org/10.2105/AJPH.2009.160184' => '10.2105/AJPH.2009.160184',
        '(doi:10.2105/AJPH.2009.160184)' => '10.2105/AJPH.2009.160184',
        '[https://doi.org/10.2105/AJPH.2009.160184]' => '10.2105/AJPH.2009.160184',
        '<10.2105/AJPH.2009.160184>' => '10.2105/AJPH.2009.160184',
        '[(doi:10.2105/AJPH.2009.160184)]' => '10.2105/AJPH.2009.160184',
        '10.11646/zootaxa.5543.3.9)' => '10.11646/zootaxa.5543.3.9',
        '10.1016/0001(99)00012-X' => '10.1016/0001(99)00012-X',
        '10.1002/(SICI)1097-4636(199706)35:4<513::AID-JBM12>3.0.CO;2-B' =>
          '10.1002/(SICI)1097-4636(199706)35:4<513::AID-JBM12>3.0.CO;2-B',
        '' => '',
        nil => nil
      }.each do |raw, normalized|
        specify raw.inspect do
          expect(Identifier::Global::Doi.normalize(raw)).to eq(normalized)
        end
      end
    end

    specify 'restoring URL from identifier' do
      id.identifier = 'http://dx.doi.org/10.2105/AJPH.2009.160184'
      id.valid? # trigger refactor
      expect(Identifier::Global::Doi.preface_doi(id.identifier)).to eq('https://doi.org/10.2105/AJPH.2009.160184')
    end
  end
end
