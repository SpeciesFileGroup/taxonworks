require 'rails_helper'

RSpec.describe LayoutItem::DepictionItem, type: :model do
  let(:layout_item_depiction_item) {
    FactoryBot.build(:valid_layout_item_depiction_item)
  }

  specify 'valid_layout_item_depiction_item is valid' do
    expect(layout_item_depiction_item.valid?).to be_truthy
  end

  specify 'composition_item_object is required' do
    layout_item_depiction_item.composition_item_object = nil
    layout_item_depiction_item.valid?
    expect(
      layout_item_depiction_item.errors.include?(:composition_item_object)
    ).to be_truthy
  end

  specify 'composition_item_object must be a Depiction' do
    layout_item_depiction_item.composition_item_object =
      FactoryBot.create(:valid_image)
    layout_item_depiction_item.valid?
    expect(
      layout_item_depiction_item.errors
        .include?(:composition_item_object_type)
    ).to be_truthy
  end

  specify 'is reachable from the Depiction' do
    layout_item_depiction_item.save!
    expect(layout_item_depiction_item.composition_item_object.layout_items)
      .to contain_exactly(layout_item_depiction_item)
  end

  specify 'destroying the depicted object destroys the item' do
    layout_item_depiction_item.save!
    layout_item_depiction_item.composition_item_object
      .depiction_object.destroy!
    expect(
      LayoutItem.where(id: layout_item_depiction_item.id).exists?
    ).to be_falsey
  end
end
