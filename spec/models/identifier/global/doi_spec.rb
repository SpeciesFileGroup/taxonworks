require 'rails_helper'

describe Identifier::Global::Doi, :type => :model do

  context 'DOI.Org' do
    let(:id) { FactoryGirl.build(:identifier_global_doi) }

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
  end
end
