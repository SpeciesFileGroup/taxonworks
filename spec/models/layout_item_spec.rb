require 'rails_helper'

RSpec.describe LayoutItem, type: :model do
  let(:layout_item) { FactoryBot.build(:valid_layout_item) }

  specify 'valid_layout_item is valid' do
    expect(layout_item.valid?).to be_truthy
  end

  specify 'composition is required' do
    layout_item.composition = nil
    layout_item.valid?
    expect(layout_item.errors.include?(:composition)).to be_truthy
  end

  specify 'composition must be a Layout' do
    layout_item.composition = FactoryBot.create(:valid_template)
    layout_item.valid?
    expect(layout_item.errors.include?(:composition)).to be_truthy
  end

  specify 'composition_item_object is not permitted' do
    layout_item.composition_item_object = FactoryBot.create(:valid_image)
    layout_item.valid?
    expect(
      layout_item.errors.include?(:composition_item_object_type)
    ).to be_truthy
  end

  context 'parent' do
    let(:layout) { FactoryBot.create(:valid_layout) }

    specify 'may be a group' do
      g = FactoryBot.create(:valid_layout_item_group_item, composition: layout)
      i = FactoryBot.build(:valid_layout_item, composition: layout, parent: g)
      expect(i.valid?).to be_truthy
    end

    specify 'may not be a non-group item' do
      p = FactoryBot.create(:valid_layout_item_depiction_item,
        composition: layout)
      i = FactoryBot.build(:valid_layout_item, composition: layout, parent: p)
      i.valid?
      expect(i.errors.include?(:parent)).to be_truthy
    end
  end
end
