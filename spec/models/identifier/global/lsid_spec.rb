require 'rails_helper'

describe Identifier::Global::Lsid, :type => :model do
  context 'LSID' do
    let(:id) { FactoryGirl.build(:identifier_global_lsid) }

    context '#identifier is validly formatted' do

      specify 'empty' do
        # identifier is empty
        expect(id.valid?).to be_falsey
      end

      specify 'any old word' do
        id.identifier = Faker::Lorem.word
        expect(id.valid?).to be_falsey
      end
    end
  end
end
