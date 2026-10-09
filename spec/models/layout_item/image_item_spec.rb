require 'rails_helper'

RSpec.describe LayoutItem::ImageItem, type: :model do
  let(:layout_item_image_item) { FactoryBot.build(:valid_layout_item_image_item) }

  specify 'valid_layout_item_image_item is valid' do
    expect(layout_item_image_item.valid?).to be_truthy
  end

  specify 'composition_item_object is required' do
    layout_item_image_item.composition_item_object = nil
    layout_item_image_item.valid?
    expect(
      layout_item_image_item.errors.include?(:composition_item_object)
    ).to be_truthy
  end

  specify 'composition_item_object must be an Image' do
    layout_item_image_item.composition_item_object = FactoryBot.create(:valid_otu)
    layout_item_image_item.valid?
    expect(
      layout_item_image_item.errors.include?(:composition_item_object_type)
    ).to be_truthy
  end

  specify 'composition_item_object may not be in another project' do
    p = FactoryBot.create(:valid_project)
    layout_item_image_item.composition_item_object =
      FactoryBot.create(:valid_image, project: p)
    layout_item_image_item.valid?
    expect(
      layout_item_image_item.errors.include?(:composition_item_object_id)
    ).to be_truthy
  end

  specify 'composition must be a Layout' do
    layout_item_image_item.composition = FactoryBot.create(:valid_template)
    layout_item_image_item.valid?
    expect(layout_item_image_item.errors.include?(:composition)).to be_truthy
  end

  specify 'is reachable from the Image' do
    layout_item_image_item.save!
    expect(layout_item_image_item.composition_item_object.layout_items)
      .to contain_exactly(layout_item_image_item)
  end

  specify 'destroying the Image destroys the item' do
    layout_item_image_item.save!
    layout_item_image_item.composition_item_object.destroy!
    expect(LayoutItem.where(id: layout_item_image_item.id).exists?).to be_falsey
  end
end
