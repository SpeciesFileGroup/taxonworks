require 'rails_helper'

RSpec.describe ProtocolRelationship, type: :model, group: :protocol do
  let(:protocol_relationship) {ProtocolRelationship.new}
  let(:protocol) { FactoryBot.create(:valid_protocol) }

  context 'validations' do
    specify 'protocol_id' do
      protocol_relationship.valid?
      expect(protocol_relationship.errors.include?(:protocol)).to be_truthy
    end

    specify '#protocol_relationship_object_type' do
      protocol_relationship.protocol = protocol
      protocol_relationship.protocol_relationship_object_id = 1  
      protocol_relationship.valid?
      expect(protocol_relationship.errors.include?(:protocol_relationship_object)).to be_truthy
    end

    specify '#protocol_relationship_object_id' do
      protocol_relationship.protocol = protocol
      protocol_relationship.protocol_relationship_object_type = 'Image' 
      protocol_relationship.valid?
      expect(protocol_relationship.errors.include?(:protocol_relationship_object)).to be_truthy
    end

    specify 'protocol_id and protocol_relationship_object_id and protocol_relationship_object_type' do
      expect(FactoryBot.build(:valid_protocol_relationship).valid?).to be_truthy
    end
  end
end
