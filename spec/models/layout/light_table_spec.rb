require 'rails_helper'

RSpec.describe Layout::LightTable, type: :model do
  let(:light_table) { FactoryBot.build(:valid_layout_light_table) }

  specify 'valid_layout_light_table is valid' do
    expect(light_table.valid?).to be_truthy
  end

  specify 'type is set' do
    expect(Layout::LightTable.new.type).to eq('Layout::LightTable')
  end

  specify 'is never community' do
    light_table.is_community = true
    light_table.valid?
    expect(light_table.errors.include?(:is_community)).to be_truthy
  end

  specify 'LayoutItems may be placed in it' do
    light_table.save!
    i = FactoryBot.create(:valid_layout_item_image_item,
      composition: light_table)
    expect(light_table.composition_items).to contain_exactly(i)
  end

  specify 'is found by Composition' do
    light_table.save!
    expect(Composition.find(light_table.id)).to be_a(Layout::LightTable)
  end
end
