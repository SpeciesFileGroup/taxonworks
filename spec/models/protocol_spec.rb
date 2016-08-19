require 'rails_helper'

RSpec.describe Protocol, type: :model do
  let(:protocol) {Protocol.new}

  context 'validation' do
    context 'fails when not given' do
      before {protocol.valid?}
      
      specify 'name' do
        expect(protocol.errors.include?(:name)).to be_truthy
      end

      specify 'short_name' do
        expect(protocol.errors.include?(:short_name)).to be_truthy
      end

      specify 'description' do
        expect(protocol.errors.include?(:description)).to be_truthy
      end

      context 'unique name' do
        before(:each){
          name_protocol = FactoryGirl.build(:valid_protocol)
          name_protocol.name = "Name1"
          name_protocol.save!
        }

        specify 'same casing' do
          new_protocol = FactoryGirl.build(:valid_protocol)
          new_protocol.name = "Name1"
          expect(new_protocol.valid?).to be_falsey
        end

        specify 'different casing' do
          new_protocol = FactoryGirl.build(:valid_protocol)
          new_protocol.name = "name1"
          expect(new_protocol.valid?).to be_falsey
        end
      end
    end

    context 'passes when given' do
      specify 'name and short_name and description' do
        expect(FactoryGirl.build(:valid_protocol).valid?).to be true
      end
    end
  end
end
