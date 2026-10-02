require 'rails_helper'

RSpec.describe Layout, type: :model do
  let(:layout) { FactoryBot.build(:valid_layout) }

  specify 'valid_layout is valid' do
    expect(layout.valid?).to be_truthy
  end

  specify 'type is set' do
    expect(Layout.new.type).to eq('Layout')
  end

  specify 'is never community' do
    layout.is_community = true
    layout.valid?
    expect(layout.errors.include?(:is_community)).to be_truthy
  end

  specify 'is_community is nil when saved' do
    layout.save!
    expect(layout.reload.is_community).to eq(nil)
  end

  specify 'project_id is set' do
    layout.save!
    expect(layout.project_id).to eq(Current.project_id)
  end
end
