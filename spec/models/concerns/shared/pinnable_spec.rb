require 'rails_helper'

describe 'Pinnable', type: :model do
  let(:user1) { FactoryBot.create(:valid_user) }
  let(:instance_with_pin) { TestPinnable.create! }

  specify '#pinboard_items' do
    expect(instance_with_pin).to respond_to(:pinboard_items)
  end

  specify '#pinboard_items 2' do
    expect(instance_with_pin.pinboard_items.count).to eq(0)
  end

  specify '#pinned? (none)' do
    expect(instance_with_pin.pinned?(user1, Current.project_id)).to be_falsey
  end

  context 'pinned' do
    let!(:pinboard_item1) { PinboardItem.create(user: user1, pinned_object: instance_with_pin)} 
    
    specify '#pinned?' do
      expect(instance_with_pin.pinned?(user1, Current.project_id)).to be_truthy
    end

    specify '#pinboard_items' do
      expect(instance_with_pin.pinboard_items.count).to eq(1)
    end
    
    specify '#pinboard_item_for' do
      expect(instance_with_pin.pinboard_item_for(user1)).to eq(pinboard_item1)
    end

    specify '#inserted? (1)' do
      expect(instance_with_pin.inserted?(user1)).to be_falsey 
    end

    specify '#inserted? (2)' do
      pinboard_item1.update_column(:is_inserted, true)
      expect(instance_with_pin.inserted?(user1)).to be_truthy
    end

    specify '.pinned_by' do
      expect(TestPinnable.pinned_by(user1.id)).to contain_exactly(instance_with_pin)
    end

    specify '.pinboard_inserted 1' do
      expect(TestPinnable.pinboard_inserted).to contain_exactly()
    end

    specify '.pinboard_inserted 2' do
      pinboard_item1.update_column(:is_inserted, true)
      expect(TestPinnable.pinboard_inserted).to contain_exactly(instance_with_pin)
    end
  end

  context 'object with pinboard_items' do
    let!(:pinboard_item1) { PinboardItem.create!(user: user1, pinned_object: instance_with_pin) }

    specify 'item was created' do
      expect(PinboardItem.count).to eq(1)
    end

    context 'on destroy' do
      before { instance_with_pin.destroy }

      specify 'related pinboard_items are destroyed 1' do
        expect(instance_with_pin.pinboard_items.reload.count).to eq(0)
      end

      specify 'related pinboard_items are destroyed 2' do
        expect(PinboardItem.count).to eq(0)
      end
    end
  end

end

class TestPinnable < ApplicationRecord
  include FakeTable
  include Shared::IsData
end
