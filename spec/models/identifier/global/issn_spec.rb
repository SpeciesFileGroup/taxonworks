require 'rails_helper'

describe Identifier::Global::Issn, :type => :model do
  context 'ISSN' do
    let(:id) { FactoryGirl.build(:identifier_global_issn) }

    context '#identifier is validly formatted' do

      specify 'empty' do
        # identifier is empty
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq('can\'t be blank')
      end

      specify 'any old word' do
        phrase        = Faker::Lorem.word
        id.identifier = phrase
        expect(id.valid?).to be_falsey
        expect(id.errors.messages[:identifier][0]).to eq("'#{phrase}' is an improperly formed ISSN.")
      end

    end
  end
end
