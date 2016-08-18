require 'rails_helper'

RSpec.describe ProtocolRelationship, type: :model do
  let(:protocol_relationship) {ProtocolRelationship.new}

  context 'validations' do

    context 'fails when not given' do
      before(:each){
        protocol_relationship.valid?
      }

      specify 'protocol_id' do
        expect(protocol_relationship.errors.include?(:protocol_id)).to be_truthy
      end

      specify 'protocol_relationship_object_id' do
        expect(protocol_relationship.errors.include?(:protocol_relationship_object_id)).to be_truthy
      end

      specify 'protocol_relationship_object_type' do
        expect(protocol_relationship.errors.include?(:protocol_relationship_object_type)).to be_truthy
      end
    end

    context 'passes when given' do
      specify 'protocol_id and protocol_relationship_object_id and protocol_relationship_object_type' do
        expect(FactoryGirl.build(:valid_protocol_relationship).valid?).to be_truthy
      end
    end
  end
end
