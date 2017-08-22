require 'rails_helper'

describe 'Protocols', type: :model, group: :protocol do
  let(:class_with_protocol) { TestProtocol.new }

  context 'associations' do
    before {class_with_protocol.save}
    specify 'has many #protocol_relatinships' do
      expect(class_with_protocol).to respond_to(:protocol_relationships) 
      expect(class_with_protocol.protocol_relationships.to_a).to eq([]) # there are no confidences yet.

      expect(class_with_protocol.protocols << FactoryGirl.build(:valid_protocol)).to be_truthy
      expect(class_with_protocol.protocols.size).to eq(1)
      expect(class_with_protocol.save).to be_truthy
      class_with_protocol.reload

      expect(class_with_protocol.protocols.count).to eq(1)
      expect(class_with_protocol.protocol_relationships.count).to eq(1)
    end
  end

  context 'methods' do
    specify '#has_protocols? with no protocols' do
      expect(class_with_protocol.has_protocols?).to eq(false)
    end

    specify 'has_protocols? with a protocol' do
      class_with_protocol.protocols << FactoryGirl.create(:valid_protocol) 
      expect(class_with_protocol.has_protocols?).to eq(true)
    end
  end
end

class TestProtocol < ApplicationRecord
  include FakeTable
  include Shared::Protocols
end


