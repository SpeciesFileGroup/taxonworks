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

  context 'composition_item_object' do
    let(:image) { FactoryBot.create(:valid_image) }

    specify 'may be an Image in the same project' do
      layout_item.composition_item_object = image
      layout_item.save!
      expect(layout_item.reload.composition_item_object).to eq(image)
    end

    specify 'may not be in another project' do
      p = FactoryBot.create(:valid_project)
      layout_item.composition_item_object =
        FactoryBot.create(:valid_otu, project: p)
      layout_item.valid?
      expect(
        layout_item.errors.include?(:composition_item_object_id)
      ).to be_truthy
    end
  end
end
