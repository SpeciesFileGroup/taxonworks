require 'rails_helper'

RSpec.describe Layout::Task, type: :model do
  let(:layout_task) { FactoryBot.build(:valid_layout_task) }

  specify 'valid_layout_task is valid' do
    expect(layout_task.valid?).to be_truthy
  end

  specify 'type is set' do
    expect(Layout::Task.new.type).to eq('Layout::Task')
  end

  specify 'is never community' do
    layout_task.is_community = true
    layout_task.valid?
    expect(layout_task.errors.include?(:is_community)).to be_truthy
  end

  specify 'TaskItems may be placed in it' do
    layout_task.save!
    i = FactoryBot.create(:valid_layout_item_task_item, composition: layout_task)
    expect(layout_task.composition_items).to contain_exactly(i)
  end

  specify 'is listed alone by type' do
    layout_task.save!
    FactoryBot.create(:valid_layout_light_table)
    expect(Composition.where(type: 'Layout::Task')).to contain_exactly(layout_task)
  end
end
