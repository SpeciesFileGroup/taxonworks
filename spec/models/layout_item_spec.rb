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
end
