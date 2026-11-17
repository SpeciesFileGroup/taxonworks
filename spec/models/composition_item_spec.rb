require 'rails_helper'

RSpec.describe CompositionItem, type: :model do
  let(:composition_item) { CompositionItem.new }
  let(:layout) { FactoryBot.create(:valid_layout) }

  specify 'is a render class' do
    expect(CompositionItem < Shared::IsRender).to be_truthy
  end

  specify 'type is required' do
    composition_item.valid?
    expect(composition_item.errors.include?(:type)).to be_truthy
  end

  specify 'composition is not required' do
    composition_item.valid?
    expect(composition_item.errors.include?(:composition)).to be_falsey
  end

  context 'opacity' do
    let(:item) { FactoryBot.build(:valid_layout_item) }

    specify 'may be nil' do
      expect(item.valid?).to be_truthy
    end

    specify 'may be 0..100' do
      item.opacity = 50.5
      expect(item.valid?).to be_truthy
    end

    specify 'may not be > 100' do
      item.opacity = 100.1
      item.valid?
      expect(item.errors.include?(:opacity)).to be_truthy
    end

    specify 'may not be < 0' do
      item.opacity = -1
      item.valid?
      expect(item.errors.include?(:opacity)).to be_truthy
    end
  end

  # LayoutItem restricts parents to groups, TemplateItems exercise the base
  # rules.
  context 'parent' do
    let(:template) { FactoryBot.create(:valid_template) }
    let(:parent) {
      FactoryBot.create(:valid_template_item, composition: template)
    }
    let(:item) {
      FactoryBot.build(:valid_template_item, composition: template, parent:)
    }

    specify 'may be in the same composition' do
      expect(item.valid?).to be_truthy
    end

    specify 'may not be in a different composition' do
      item.composition = FactoryBot.create(:valid_template)
      item.valid?
      expect(item.errors.include?(:parent)).to be_truthy
    end

    specify 'may not be self' do
      parent.parent = parent
      parent.valid?
      expect(parent.errors.include?(:parent)).to be_truthy
    end

    specify 'may not be a descendant' do
      item.save!
      parent.parent = item
      parent.valid?
      expect(parent.errors.include?(:parent)).to be_truthy
    end

    specify 'may not be under a cycle already in the data' do
      item.save!
      parent.update_columns(parent_id: item.id)
      c = FactoryBot.build(:valid_template_item,
        composition: item.composition, parent: item)
      expect(Timeout.timeout(5) { c.valid? }).to be_falsey
      expect(c.errors.include?(:parent)).to be_truthy
    end

    specify 'destroying a parent destroys its children' do
      item.save!
      parent.destroy!
      expect(CompositionItem.where(id: item.id).exists?).to be_falsey
    end
  end

  context 'composition' do
    specify 'may not change once saved' do
      i = FactoryBot.create(:valid_layout_item_group_item, composition: layout)
      i.composition = FactoryBot.create(:valid_layout)
      i.valid?
      expect(i.errors.include?(:composition)).to be_truthy
    end
  end

  context 'position' do
    specify 'is ordered within composition and parent' do
      a = FactoryBot.create(:valid_layout_item_group_item, composition: layout)
      b = FactoryBot.create(:valid_layout_item, composition: layout)
      c = FactoryBot.create(:valid_layout_item, composition: layout, parent: a)
      d = FactoryBot.create(:valid_layout_item)

      expect([a, b, c, d].map(&:position)).to eq([1, 2, 1, 1])
    end

    context 'among siblings' do
      let!(:a) { FactoryBot.create(:valid_layout_item, composition: layout) }
      let!(:b) { FactoryBot.create(:valid_layout_item, composition: layout) }
      let!(:c) { FactoryBot.create(:valid_layout_item, composition: layout) }

      def positions(*items) = items.map { |i| i.reload.position }

      specify 'an explicit position shifts the siblings at and below it' do
        d = FactoryBot.create(:valid_layout_item,
          composition: layout, position: 2)
        expect(positions(a, d, b, c)).to eq([1, 2, 3, 4])
      end

      specify 'moving an item reorders the siblings between' do
        c.update!(position: 1)
        expect(positions(c, a, b)).to eq([1, 2, 3])
      end

      specify 'destroying an item closes the gap' do
        a.destroy!
        expect(positions(b, c)).to eq([1, 2])
      end

      specify 'a new parent closes the old gap and appends to the new list' do
        group = FactoryBot.create(:valid_layout_item_group_item,
          composition: layout)
        member = FactoryBot.create(:valid_layout_item,
          composition: layout, parent: group)
        a.update!(parent: group)
        expect(positions(b, c, group)).to eq([1, 2, 3])
        expect(positions(member, a)).to eq([1, 2])
      end
    end
  end

  context 'project' do
    specify 'is the composition project' do
      i = FactoryBot.create(:valid_layout_item, composition: layout)
      expect(i.project_id).to eq(layout.project_id)
    end

    specify 'a composition in another project is invalid' do
      other = FactoryBot.create(:valid_layout,
        project: FactoryBot.create(:valid_project))
      i = FactoryBot.build(:valid_layout_item_group_item, composition: other)
      i.valid?
      expect(i.errors.include?(:composition_id)).to be_truthy
    end

    context 'when the composition is community' do
      before do
        allow(Template).to receive(:community_permitted?).and_return(true)
        allow(TemplateItem).to receive(:composition_item_object_permitted?)
          .and_return(true)
      end
      let(:template) { FactoryBot.create(:valid_template, is_community: true) }

      specify 'is nil' do
        i = FactoryBot.create(:valid_template_item, composition: template)
        expect(i.reload.project_id).to eq(nil)
      end

      specify 'composition_item_object is not permitted' do
        i = FactoryBot.build(:valid_template_item, composition: template, composition_item_object: FactoryBot.create(:valid_otu))
        i.valid?
        expect(i.errors.include?(:composition_item_object)).to be_truthy
      end

      specify 'composition may not become community when items reference objects' do
        t = FactoryBot.create(:valid_template)
        FactoryBot.create(:valid_template_item, composition: t, composition_item_object: FactoryBot.create(:valid_otu))
        t.is_community = true
        t.valid?
        expect(t.errors.include?(:is_community)).to be_truthy
      end

      specify 'follows the composition becoming community' do
        t = FactoryBot.create(:valid_template)
        i = FactoryBot.create(:valid_template_item, composition: t)
        t.update!(is_community: true)
        expect(i.reload.project_id).to eq(nil)
      end

      specify 'follows the composition becoming project' do
        i = FactoryBot.create(:valid_template_item, composition: template)
        template.update!(is_community: false)
        expect(i.reload.project_id).to eq(Current.project_id)
      end
    end
  end

  specify 'composition_item_object is not permitted by default' do
    i = FactoryBot.build(:valid_layout_item,
      composition_item_object: FactoryBot.create(:valid_otu))
    i.valid?
    expect(i.errors.include?(:composition_item_object_type)).to be_truthy
  end

  specify 'is not community at the class level' do
    expect(CompositionItem.is_community?).to be_falsey
  end

  # Permitted targets must get dependent cleanup from a target concern.
  specify 'every permitted target class includes Shared::LayoutItems' do
    # descendants only sees loaded classes
    expect(Rails.application.config.eager_load).to be(true)
    targets = ApplicationRecord.descendants.select { |k|
      !k.abstract_class? && k.table_exists? &&
        LayoutItem.descendants.any? { |s|
          s.composition_item_object_permitted?(k)
        }
    }
    expect(targets).to include(Image, Depiction)
    expect(targets.reject { |k| k < Shared::LayoutItems }).to eq([])
  end

  specify 'destroying the composition destroys its items' do
    i = FactoryBot.create(:valid_layout_item_group_item, composition: layout)
    c = FactoryBot.create(:valid_layout_item, composition: layout, parent: i)
    layout.destroy!
    expect(CompositionItem.where(id: [i.id, c.id]).exists?).to be_falsey
  end

  specify 'destroying the composition destroys nested groups and members' do
    outer = FactoryBot.create(:valid_layout_item_group_item, composition: layout)
    inner = FactoryBot.create(:valid_layout_item_group_item,
      composition: layout, parent: outer)
    c = FactoryBot.create(:valid_layout_item, composition: layout, parent: inner)
    layout.destroy!
    expect(CompositionItem.where(id: [outer.id, inner.id, c.id]).exists?)
      .to be_falsey
  end
end
