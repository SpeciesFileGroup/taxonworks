require 'rails_helper'

RSpec.describe LeadItem, type: :model do

  describe '::consolidate_descendant_items' do
    let(:root) { FactoryBot.create(:valid_lead) }
    let(:otu1) { FactoryBot.create(:valid_otu) }
    let(:otu2) { FactoryBot.create(:valid_otu) }
    let(:otu3) { FactoryBot.create(:valid_otu) }

    context 'with items on a single leaf' do
      let!(:left) { root.children.create!(text: 'left') }
      let!(:right) { root.children.create!(text: 'right') }

      before do
        FactoryBot.create(:valid_lead_item, lead: left, otu: otu1)
        FactoryBot.create(:valid_lead_item, lead: left, otu: otu2)
      end

      specify 'moves items to target' do
        LeadItem.consolidate_descendant_items(root, right)

        expect(left.reload.lead_items.count).to eq(0)
        expect(right.reload.lead_items.pluck(:otu_id))
          .to contain_exactly(otu1.id, otu2.id)
      end

      specify 'returns the target lead' do
        result = LeadItem.consolidate_descendant_items(root, right)
        expect(result).to eq(right)
      end
    end

    context 'with items on multiple leaves' do
      let!(:left) { root.children.create!(text: 'left') }
      let!(:right) { root.children.create!(text: 'right') }

      before do
        FactoryBot.create(:valid_lead_item, lead: left, otu: otu1)
        FactoryBot.create(:valid_lead_item, lead: right, otu: otu2)
      end

      specify 'consolidates all items to target' do
        target = FactoryBot.create(:valid_lead)

        LeadItem.consolidate_descendant_items(root, target)

        expect(left.reload.lead_items.count).to eq(0)
        expect(right.reload.lead_items.count).to eq(0)
        expect(target.reload.lead_items.pluck(:otu_id))
          .to contain_exactly(otu1.id, otu2.id)
      end
    end

    context 'when target is one of the leaves' do
      let!(:left) { root.children.create!(text: 'left') }
      let!(:right) { root.children.create!(text: 'right') }

      before do
        FactoryBot.create(:valid_lead_item, lead: left, otu: otu1)
        FactoryBot.create(:valid_lead_item, lead: right, otu: otu2)
      end

      specify 'does not move items already on target' do
        LeadItem.consolidate_descendant_items(root, right)

        expect(left.reload.lead_items.count).to eq(0)
        expect(right.reload.lead_items.pluck(:otu_id))
          .to contain_exactly(otu1.id, otu2.id)
      end

      specify 'target retains its original item' do
        original_item_id = right.lead_items.first.id

        LeadItem.consolidate_descendant_items(root, right)

        expect(right.reload.lead_items.pluck(:id))
          .to include(original_item_id)
      end
    end

    context 'with duplicate otu_ids' do
      let!(:left) { root.children.create!(text: 'left') }
      let!(:right) { root.children.create!(text: 'right') }

      before do
        FactoryBot.create(:valid_lead_item, lead: left, otu: otu1)
        FactoryBot.create(:valid_lead_item, lead: right, otu: otu1)
      end

      specify 'deletes duplicates from source' do
        LeadItem.consolidate_descendant_items(root, right)

        expect(left.reload.lead_items.count).to eq(0)
      end

      specify 'does not create duplicates on target' do
        LeadItem.consolidate_descendant_items(root, right)

        expect(right.reload.lead_items.where(otu_id: otu1.id).count).to eq(1)
      end

      specify 'returns the target' do
        result = LeadItem.consolidate_descendant_items(root, right)
        expect(result).to eq(right)
      end
    end

    context 'when all source items are duplicates' do
      let!(:left) { root.children.create!(text: 'left') }
      let!(:right) { root.children.create!(text: 'right') }

      before do
        FactoryBot.create(:valid_lead_item, lead: left, otu: otu1)
        FactoryBot.create(:valid_lead_item, lead: left, otu: otu2)
        FactoryBot.create(:valid_lead_item, lead: right, otu: otu1)
        FactoryBot.create(:valid_lead_item, lead: right, otu: otu2)
      end

      specify 'deletes all source items' do
        LeadItem.consolidate_descendant_items(root, right)

        expect(left.reload.lead_items.count).to eq(0)
      end

      specify 'target otus unchanged' do
        LeadItem.consolidate_descendant_items(root, right)

        expect(right.reload.lead_items.pluck(:otu_id))
          .to contain_exactly(otu1.id, otu2.id)
      end
    end

    context 'with mixed duplicates and unique items' do
      let!(:left) { root.children.create!(text: 'left') }
      let!(:right) { root.children.create!(text: 'right') }

      before do
        FactoryBot.create(:valid_lead_item, lead: left, otu: otu1)  # duplicate
        FactoryBot.create(:valid_lead_item, lead: left, otu: otu2)  # unique
        FactoryBot.create(:valid_lead_item, lead: right, otu: otu1) # already on target
      end

      specify 'deletes duplicates and moves unique items' do
        LeadItem.consolidate_descendant_items(root, right)

        expect(left.reload.lead_items.count).to eq(0)
        expect(right.reload.lead_items.pluck(:otu_id))
          .to contain_exactly(otu1.id, otu2.id)
      end
    end

    context 'with nil target' do
      let!(:left) { root.children.create!(text: 'left') }
      let!(:right) { root.children.create!(text: 'right') }

      before do
        FactoryBot.create(:valid_lead_item, lead: left, otu: otu1)
      end

      specify 'creates a placeholder lead' do
        result = LeadItem.consolidate_descendant_items(root, nil)

        expect(result).to be_a(Lead)
        expect(result.text).to include('PLACEHOLDER')
      end

      specify 'moves items to the placeholder' do
        result = LeadItem.consolidate_descendant_items(root, nil)

        expect(left.reload.lead_items.count).to eq(0)
        expect(result.lead_items.pluck(:otu_id)).to eq([otu1.id])
      end
    end

    context 'with deeper tree structure' do
      let!(:left) { root.children.create!(text: 'left') }
      let!(:right) { root.children.create!(text: 'right') }
      let!(:left_left) { left.children.create!(text: 'left-left') }
      let!(:left_right) { left.children.create!(text: 'left-right') }

      before do
        # Items only on leaf nodes
        FactoryBot.create(:valid_lead_item, lead: left_left, otu: otu1)
        FactoryBot.create(:valid_lead_item, lead: left_right, otu: otu2)
        FactoryBot.create(:valid_lead_item, lead: right, otu: otu3)
      end

      specify 'consolidates from all leaves' do
        target = FactoryBot.create(:valid_lead)

        LeadItem.consolidate_descendant_items(root, target)

        expect(left_left.reload.lead_items.count).to eq(0)
        expect(left_right.reload.lead_items.count).to eq(0)
        expect(right.reload.lead_items.count).to eq(0)
        expect(target.reload.lead_items.pluck(:otu_id)).to contain_exactly(otu1.id, otu2.id, otu3.id)
      end

      specify 'when target is a leaf, excludes it from sources' do
        LeadItem.consolidate_descendant_items(root, right)

        expect(left_left.reload.lead_items.count).to eq(0)
        expect(left_right.reload.lead_items.count).to eq(0)
        expect(right.reload.lead_items.pluck(:otu_id))
          .to contain_exactly(otu1.id, otu2.id, otu3.id)
      end
    end
  end

end
