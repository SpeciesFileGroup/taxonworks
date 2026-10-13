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

  context '.select_optimized' do
    let(:other_user) { FactoryBot.create(:valid_user) }
    let!(:a) { FactoryBot.create(:valid_layout_light_table) }
    let!(:b) { FactoryBot.create(:valid_layout_light_table) }
    let!(:c) { FactoryBot.create(:valid_layout_light_table) }

    def select_optimized(klass = Layout::LightTable)
      klass.select_optimized(user_id, project_id)
    end

    specify 'recent is ordered by the user\'s latest change, most recent first' do
      a.update_columns(updated_at: 3.days.ago)
      b.update_columns(updated_at: 2.days.ago)
      c.update_columns(updated_at: 1.day.ago)
      expect(select_optimized[:recent]).to eq([c, b, a])
    end

    specify 'recent counts changes to items' do
      [a, b, c].each { |l| l.update_columns(updated_at: 2.days.ago) }
      FactoryBot.create(:valid_layout_item_light_table_item, composition: a)
      expect(select_optimized[:recent].first).to eq(a)
    end

    specify 'recent ignores other users\' changes' do
      a.update_columns(updated_by_id: other_user.id)
      expect(select_optimized[:recent]).to contain_exactly(b, c)
    end

    specify 'recent ignores other users\' item changes' do
      a.update_columns(updated_by_id: other_user.id)
      i = FactoryBot.create(:valid_layout_item_light_table_item, composition: a)
      i.update_columns(updated_by_id: other_user.id)
      expect(select_optimized[:recent]).to contain_exactly(b, c)
    end

    specify 'is limited to the class it is called on' do
      l = FactoryBot.create(:valid_layout)
      expect(select_optimized[:recent]).not_to include(l)
      expect(select_optimized(Composition)[:recent]).to include(l, a)
    end

    specify 'is limited to the project' do
      o = FactoryBot.create(:valid_layout_light_table,
        project: FactoryBot.create(:valid_project))
      expect(select_optimized[:recent]).not_to include(o)
    end

    specify 'pinboard and quick include pinned Compositions' do
      FactoryBot.create(:valid_pinboard_item,
        pinned_object: a, user: User.find(user_id), is_inserted: true)
      expect(select_optimized[:pinboard]).to eq([a])
      expect(select_optimized[:quick]).to include(a)
    end
  end
end
