require 'rails_helper'

RSpec.describe LayoutItem::GroupItem, type: :model do
  let(:group_item) { FactoryBot.build(:valid_layout_item_group_item) }

  specify 'valid_layout_item_group_item is valid' do
    expect(group_item.valid?).to be_truthy
  end

  specify 'text labels the group' do
    group_item.text = 'Aphelinus sp. A'
    expect(group_item.save).to be_truthy
  end

  specify 'composition_item_object is not permitted' do
    group_item.composition_item_object = FactoryBot.create(:valid_image)
    group_item.valid?
    expect(
      group_item.errors.include?(:composition_item_object_type)
    ).to be_truthy
  end

  specify 'composition must be a Layout' do
    group_item.composition = FactoryBot.create(:valid_template)
    group_item.valid?
    expect(group_item.errors.include?(:composition)).to be_truthy
  end

  context 'translation only' do
    %i[z zoom rotation_z width height opacity].each do |a|
      specify "#{a} is not supported" do
        group_item.send("#{a}=", 1)
        group_item.valid?
        expect(group_item.errors.include?(a)).to be_truthy
      end
    end

    specify 'x and y are supported' do
      group_item.x = 10
      group_item.y = 20
      expect(group_item.valid?).to be_truthy
    end
  end

  context 'destroy (ungroup)' do
    let(:layout) { FactoryBot.create(:valid_layout_light_table) }
    let(:group) {
      FactoryBot.create(:valid_layout_item_group_item,
        composition: layout, x: 100, y: 50)
    }
    let!(:a) {
      FactoryBot.create(:valid_layout_item_light_table_item,
        composition: layout, parent: group, x: 10, y: 5)
    }
    let!(:b) {
      FactoryBot.create(:valid_layout_item_light_table_item,
        composition: layout, parent: group)
    }

    specify 'keeps the members' do
      group.destroy!
      expect(CompositionItem.where(id: [a.id, b.id]).count).to eq(2)
    end

    specify 'destroys the group' do
      group.destroy!
      expect(CompositionItem.where(id: group.id).exists?).to be_falsey
    end

    specify 'adds the offset to members' do
      group.destroy!
      expect([a.reload.x, a.y]).to eq([110.0, 55.0])
    end

    specify 'treats nil member position as 0' do
      group.destroy!
      expect([b.reload.x, b.y]).to eq([100.0, 50.0])
    end

    specify 'nil group offset leaves members in place' do
      group.update!(x: nil, y: nil)
      group.destroy!
      expect([a.reload.x, a.y]).to eq([10.0, 5.0])
    end

    specify 'members move to the group\'s parent' do
      outer = FactoryBot.create(:valid_layout_item_group_item,
        composition: layout, x: 1, y: 1)
      group.update!(parent: outer)
      group.destroy!
      expect(a.reload.parent).to eq(outer)
      expect([a.x, a.y]).to eq([110.0, 55.0])
    end

    specify 'a nested group moves up with its members untouched' do
      inner = FactoryBot.create(:valid_layout_item_group_item,
        composition: layout, parent: group, x: 7, y: 3)
      c = FactoryBot.create(:valid_layout_item_light_table_item,
        composition: layout, parent: inner, x: 2, y: 2)
      group.destroy!
      expect([inner.reload.parent_id, inner.x, inner.y])
        .to eq([nil, 107.0, 53.0])
      expect([c.reload.parent, c.x, c.y]).to eq([inner, 2.0, 2.0])
    end

    specify 'members keep their order, after the parent\'s other items' do
      other = FactoryBot.create(:valid_layout_item_group_item,
        composition: layout)
      c = FactoryBot.create(:valid_layout_item_light_table_item,
        composition: layout, parent: group)
      c.insert_at(1)
      group.destroy!
      expect(
        layout.composition_items.where(parent_id: nil).order(:position)
          .pluck(:id, :position)
      ).to eq([[other.id, 1], [c.id, 2], [a.id, 3], [b.id, 4]])
    end

    specify 'is skipped when the Composition is destroyed' do
      layout.destroy!
      expect(CompositionItem.where(id: [group.id, a.id, b.id]).exists?)
        .to be_falsey
    end
  end

  context 'members' do
    before {
      group_item.composition = FactoryBot.create(:valid_layout_light_table)
      group_item.save!
    }
    let!(:member) {
      FactoryBot.create(:valid_layout_item_light_table_item,
        composition: group_item.composition, parent: group_item)
    }

    specify 'are its children' do
      expect(group_item.children).to contain_exactly(member)
    end

    specify 'are kept when it is destroyed' do
      group_item.destroy!
      expect(CompositionItem.where(id: member.id).exists?).to be_truthy
    end

    specify 'may not be in another Layout' do
      member.composition = FactoryBot.create(:valid_layout)
      member.valid?
      expect(member.errors.include?(:parent)).to be_truthy
    end
  end
end
