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

  context 'version' do
    let(:layout) { FactoryBot.build(:valid_layout) }

    specify 'is optional' do
      layout.version = nil
      expect(layout.valid?).to be_truthy
    end

    specify 'is valid when semantic' do
      layout.version = '1.2.3'
      expect(layout.valid?).to be_truthy
    end

    specify 'is invalid when not semantic' do
      layout.version = '1.2'
      layout.valid?
      expect(layout.errors.include?(:version)).to be_truthy
    end

    specify 'is invalid when all zeros' do
      layout.version = '0.0.0'
      layout.valid?
      expect(layout.errors.include?(:version)).to be_truthy
    end

    specify 'blank is normalized to nil' do
      layout.version = ''
      layout.valid?
      expect(layout.version).to eq(nil)
    end
  end

  context 'uniqueness' do
    let!(:layout) { FactoryBot.create(:valid_layout, name: 'Drawer', version: '1.0.0') }

    specify 'same type, name, version is invalid' do
      expect(FactoryBot.build(:valid_layout, name: 'Drawer', version: '1.0.0').valid?).to be_falsey
    end

    specify 'same type, name, nil version is invalid' do
      FactoryBot.create(:valid_layout, name: 'Box')
      expect(FactoryBot.build(:valid_layout, name: 'Box').valid?).to be_falsey
    end

    specify 'nil version is enforced by the database' do
      FactoryBot.create(:valid_layout, name: 'Box')
      l = FactoryBot.build(:valid_layout, name: 'Box')
      expect { l.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    specify 'different version is valid' do
      expect(FactoryBot.build(:valid_layout, name: 'Drawer', version: '1.0.1').valid?).to be_truthy
    end

    specify 'different type is valid' do
      expect(FactoryBot.build(:valid_template, name: 'Drawer', version: '1.0.0').valid?).to be_truthy
    end

    specify 'different project is valid' do
      expect(FactoryBot.build(:valid_layout, name: 'Drawer', version: '1.0.0', project: FactoryBot.create(:valid_project)).valid?).to be_truthy
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
