require 'rails_helper'

RSpec.describe PinboardItem do
  let(:pinboard_item) { PinboardItem.new }

  specify 'good pinboard_item_type subclass' do
    pinboard_item.pinned_object_type = 'Keyword'
    pinboard_item.valid?
    expect(pinboard_item.errors.messages.keys).to_not include(:pinned_object_type)
  end

  specify 'bad pinboard_item_type' do
    p = FactoryBot.create(:valid_pinboard_item)
    p.pinned_object_type = 'Foo'
    expect {p.save!}.to raise_error NameError, /uninitialized constant Foo/
  end

  context 'associations' do
    specify '#user' do
      expect(pinboard_item.user = User.new).to be_truthy
    end

    specify '#pinned_object' do
      expect(pinboard_item.pinned_object = Specimen.new).to be_truthy
    end
  end

  specify 'by default #is_inserted? is false' do
    expect(pinboard_item.is_inserted?).to eq(false)
  end

  specify '#cross_project? when unset' do
    expect(pinboard_item.is_cross_project?).to eq(false)
  end

  specify '#cross_project? when set 1' do
    pinboard_item.is_cross_project =  false
    expect(pinboard_item.is_cross_project?).to eq(false)
  end

  specify '#cross_project? when set 2' do
    pinboard_item.is_cross_project = true
    expect(pinboard_item.is_cross_project?).to eq(true)
  end

  context 'inserted' do

    let!(:a) { PinboardItem.create!(pinned_object: FactoryBot.create(:valid_otu, name: 'smorf'), is_inserted: true, user_id: 1)  }
    let!(:b) { PinboardItem.create!(pinned_object: FactoryBot.create(:valid_otu, name: 'blorf'), is_inserted: false, user_id: 1) }
    let!(:c) { PinboardItem.create!(pinned_object: FactoryBot.create(:valid_specimen,), is_inserted: true, user_id: 1) }

    specify '.reorder_by' do
      PinboardItem.reorder_by([b.id, a.id])
      expect(b.position > a.position).to be_truthy
    end

    specify '#is_inserted: true' do
      b.update_attribute(:is_inserted, true)
      b.reload
      expect(b.is_inserted?).to be(true)
    end

    specify '#is_inserted: "true"' do
      b.update_attribute(:is_inserted, 'true')
      b.reload
      expect(b.is_inserted?).to be(true)
    end

    context 'when is_inserted: true set' do
      before { b.update_attribute(:is_inserted, true)}

      specify 'others are false' do
        expect(a.reload.is_inserted?).to be(false)
      end

      specify 'but unrelated records remain set' do
        expect(c.is_inserted?).to be(true)
      end
    end
  end

  context 'validation' do
    specify '#user_id is required' do
      pinboard_item.valid?
      expect(pinboard_item.errors.include?(:user_id)).to be(true)
    end

    specify '#is_cross_project' do
      a = PinboardItem.new(pinned_object: FactoryBot.create(:valid_serial), is_cross_project: true, user_id: 1)
      expect(a.save).to be_truthy
      b = PinboardItem.new(pinned_object: FactoryBot.create(:valid_otu), is_cross_project: true, user_id: 1)
      expect(b.save).to be_falsey
    end
  end
end
