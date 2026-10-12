require 'rails_helper'

RSpec.describe Composition, type: :model do
  let(:composition) { Composition.new }

  context 'validation' do
    before { composition.valid? }

    specify 'type is required' do
      expect(composition.errors.include?(:type)).to be_truthy
    end

    specify 'name is required' do
      expect(composition.errors.include?(:name)).to be_truthy
    end

    specify 'a bare Composition can not be saved' do
      composition.name = 'Foo'
      expect(composition.save).to be_falsey
    end
  end

  specify 'is a render class' do
    expect(Composition < Shared::IsRender).to be_truthy
  end

  specify 'new with type instantiates the subclass' do
    expect(Composition.new(type: 'Layout')).to be_a(Layout)
  end

  context 'uniqueness' do
    let!(:layout) { FactoryBot.create(:valid_layout, name: 'Drawer') }

    specify 'same type, name is invalid' do
      expect(FactoryBot.build(:valid_layout, name: 'Drawer').valid?).to be_falsey
    end

    specify 'same type, name is enforced by the database' do
      l = FactoryBot.build(:valid_layout, name: 'Drawer')
      expect { l.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    specify 'different type is valid' do
      expect(FactoryBot.build(:valid_template, name: 'Drawer').valid?).to be_truthy
    end

    specify 'different project is valid' do
      expect(FactoryBot.build(:valid_layout, name: 'Drawer', project: FactoryBot.create(:valid_project)).valid?).to be_truthy
    end
  end

  context 'scopes' do
    specify '.visible_to_project includes project and community records' do
      l = FactoryBot.create(:valid_layout)
      o = FactoryBot.create(:valid_layout, project: FactoryBot.create(:valid_project))
      allow(Template).to receive(:community_permitted?).and_return(true)
      t = FactoryBot.create(:valid_template, is_community: true)

      expect(Composition.visible_to_project(l.project_id)).to contain_exactly(l, t)
    end
  end
end
