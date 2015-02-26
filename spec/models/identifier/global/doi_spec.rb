require 'rails_helper'

describe Identifier::Global::Doi, :type => :model do
  context 'DOI.Org' do
    let(:id) { FactoryGirl.build(:identifier_global_doi)}
    specify '#identifier is validly formatted' do
      # identifier is empty
      expect(id.valid?).to be_falsey

      id.identifier = Faker::Lorem.word
      expect(id.valid?).to be_falsey

      id.identifier = '10.12345/TaxonWorks-' + Faker::Number.number(45)
      expect(id.valid?).to be_truthy
    end
  end
end
