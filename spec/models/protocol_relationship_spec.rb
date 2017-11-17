require 'rails_helper'

RSpec.describe ProtocolRelationship, type: :model, group: :protocol do
  let(:protocol_relationship) {ProtocolRelationship.new}
  let(:protocol) { FactoryBot.create(:valid_protocol) }

  context 'validations' do

    context 'adds error' do
      before(:each){
        protocol_relationship.valid?
      }

      specify 'protocol_id' do
        expect(protocol_relationship.errors.include?(:protocol)).to be_truthy
      end
    end
    context 'raises for polymorphic fields' do

      before{protocol_relationship.protocol = FactoryBot.create(:valid_protocol)}

      specify '#protocol_relationship_object_type' do
        protocol_relationship.protocol_relationship_object_id = 1  
        expect{protocol_relationship.save}.to raise_error ActiveRecord::StatementInvalid
      end

      specify '#protocol_relationship_object_id' do
        protocol_relationship.protocol_relationship_object_type = 'Image' 
        expect{protocol_relationship.save}.to raise_error ActiveRecord::StatementInvalid 
      end
    end

    context 'passes when given' do
      specify 'protocol_id and protocol_relationship_object_id and protocol_relationship_object_type' do
        expect(FactoryBot.build(:valid_protocol_relationship).valid?).to be_truthy
      end
    end
  end
end
