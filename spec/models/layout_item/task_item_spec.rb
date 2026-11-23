require 'rails_helper'

RSpec.describe LayoutItem::TaskItem, type: :model do
  let(:task_item) { FactoryBot.build(:valid_layout_item_task_item) }

  specify 'valid_layout_item_task_item is valid' do
    expect(task_item.valid?).to be_truthy
  end

  specify 'composition_item_object is required' do
    task_item.composition_item_object = nil
    task_item.valid?
    expect(task_item.errors.include?(:composition_item_object)).to be_truthy
  end

  specify 'composition_item_object may not be anything but a CollectionObject' do
    task_item.composition_item_object = FactoryBot.create(:valid_image)
    task_item.valid?
    expect(task_item.errors.include?(:composition_item_object_type)).to be_truthy
  end

  specify 'composition must be a Layout::Task' do
    task_item.composition = FactoryBot.create(:valid_layout_light_table)
    task_item.valid?
    expect(task_item.errors.include?(:composition)).to be_truthy
  end

  specify 'a CollectionObject is a TaskItem at most once per Composition' do
    task_item.save!
    i = FactoryBot.build(:valid_layout_item_task_item,
      composition: task_item.composition,
      composition_item_object: task_item.composition_item_object)
    i.valid?
    expect(i.errors.include?(:composition_item_object_id)).to be_truthy
  end

  specify 'a CollectionObject may be a TaskItem in another Composition' do
    task_item.save!
    i = FactoryBot.build(:valid_layout_item_task_item,
      composition_item_object: task_item.composition_item_object)
    expect(i.valid?).to be_truthy
  end

  specify 'new TaskItems are appended to the bottom' do
    task_item.save!
    i = FactoryBot.create(:valid_layout_item_task_item, composition: task_item.composition)
    expect(i.position).to eq(task_item.position + 1)
  end

  specify 'is reachable from the CollectionObject' do
    task_item.save!
    expect(task_item.composition_item_object.layout_items).to contain_exactly(task_item)
  end
end
