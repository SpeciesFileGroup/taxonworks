require 'rails_helper'

describe 'Pinnable', type: :model do
  let(:user1) { FactoryGirl.create(:valid_user) }
  let(:instance_with_pin) { TestPinnable.new }

  context 'associations' do
    specify 'has many pins/#pinned?' do
      # test that the method notations exists
      expect(instance_with_pin).to respond_to(:pinboard_items)
      expect(instance_with_pin.pinboard_items.size == 0).to be_truthy
      # currently has no pins
    end
  end

  context 'methods' do
    specify '#pinned? (none)' do
      expect(instance_with_pin).to respond_to(:pinboard_items)
      expect(instance_with_pin.pinned?(user1)).to be_falsey
    end
    specify '#pinned? (1)' do
      instance_with_pin.save
      pinboard_item1 = PinboardItem.new(user: user1, pinned_object: instance_with_pin)
      expect(pinboard_item1.save).to be_truthy
      expect(instance_with_pin.pinned?(user1)).to be_truthy
      expect(instance_with_pin.pinboard_items.size == 1).to be_truthy
    end
  end

  context 'object with pins' do
    context 'on destroy' do
      specify 'attached pins are destroyed' do
        expect(PinboardItem.count).to eq(0)
        instance_with_pin.save
        pinboard_item1 = PinboardItem.new(user: user1, pinned_object: instance_with_pin)
        expect(pinboard_item1.save).to be_truthy
        expect(instance_with_pin.pinned?(user1)).to be_truthy
        expect(PinboardItem.count).to eq(1)
        expect(instance_with_pin.destroy).to be_truthy
        expect(PinboardItem.count).to eq(0)
      end
    end
  end
end

class TestPinnable < ApplicationRecord
  include FakeTable
  include Shared::IsData
end
