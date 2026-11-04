require 'rails_helper'

RSpec.describe LayoutItem::LightTableItem, type: :model do
  let(:light_table_item) {
    FactoryBot.build(:valid_layout_item_light_table_item)
  }

  specify 'valid_layout_item_light_table_item is valid' do
    expect(light_table_item.valid?).to be_truthy
  end

  specify 'composition_item_object is required' do
    light_table_item.composition_item_object = nil
    light_table_item.valid?
    expect(
      light_table_item.errors.include?(:composition_item_object)
    ).to be_truthy
  end

  specify 'composition_item_object may be a Depiction' do
    light_table_item.composition_item_object = FactoryBot.create(:valid_depiction)
    expect(light_table_item.valid?).to be_truthy
  end

  specify 'composition_item_object may be an Image' do
    light_table_item.composition_item_object = FactoryBot.create(:valid_image)
    expect(light_table_item.valid?).to be_truthy
  end

  specify 'composition_item_object may not be anything else' do
    light_table_item.composition_item_object = FactoryBot.create(:valid_otu)
    light_table_item.valid?
    expect(
      light_table_item.errors.include?(:composition_item_object_type)
    ).to be_truthy
  end

  specify 'composition_item_object may not be in another project' do
    p = FactoryBot.create(:valid_project)
    light_table_item.composition_item_object =
      FactoryBot.create(:valid_image, project: p)
    light_table_item.valid?
    expect(
      light_table_item.errors.include?(:composition_item_object_id)
    ).to be_truthy
  end

  specify 'composition must be a light table' do
    light_table_item.composition = FactoryBot.create(:valid_layout)
    light_table_item.valid?
    expect(light_table_item.errors.include?(:composition)).to be_truthy
  end

  specify 'is reachable from the Depiction' do
    light_table_item.save!
    expect(light_table_item.composition_item_object.layout_items)
      .to contain_exactly(light_table_item)
  end

  specify 'destroying the depicted object destroys the item' do
    light_table_item.save!
    light_table_item.composition_item_object.depiction_object.destroy!
    expect(LayoutItem.where(id: light_table_item.id).exists?).to be_falsey
  end

  specify 'destroying the Image destroys the item' do
    light_table_item.composition_item_object = FactoryBot.create(:valid_image)
    light_table_item.save!
    light_table_item.composition_item_object.destroy!
    expect(LayoutItem.where(id: light_table_item.id).exists?).to be_falsey
  end
end
