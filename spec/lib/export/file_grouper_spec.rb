require 'rails_helper'

describe Export::FileGrouper, type: :model do
  let(:grouper) { described_class.new }

  describe '#group' do
    let(:size_extractor) { ->(item) { item[:size] } }

    specify 'groups items that fit within max_bytes' do
      items = [
        { id: 1, size: 100 },
        { id: 2, size: 100 },
        { id: 3, size: 100 }
      ]

      groups = grouper.group(items: items, max_bytes: 500, size_extractor: size_extractor)

      expect(groups.length).to eq(1)
      expect(groups.first.length).to eq(3)
    end

    specify 'splits items into multiple groups when size exceeds max' do
      items = [
        { id: 1, size: 100 },
        { id: 2, size: 100 },
        { id: 3, size: 100 }
      ]

      groups = grouper.group(items: items, max_bytes: 250, size_extractor: size_extractor)

      expect(groups.length).to eq(2)
      expect(groups[0].map { |i| i[:id] }).to eq([1, 2])
      expect(groups[1].map { |i| i[:id] }).to eq([3])
    end

    specify 'places oversized items in their own group' do
      items = [
        { id: 1, size: 500 }
      ]

      groups = grouper.group(items: items, max_bytes: 100, size_extractor: size_extractor)

      expect(groups.length).to eq(1)
      expect(groups.first.first[:id]).to eq(1)
    end

    specify 'preserves item order' do
      items = [
        { id: 1, size: 100 },
        { id: 2, size: 100 },
        { id: 3, size: 100 }
      ]

      groups = grouper.group(items: items, max_bytes: 150, size_extractor: size_extractor)

      all_ids = groups.flatten.map { |item| item[:id] }
      expect(all_ids).to eq([1, 2, 3])
    end

    specify 'returns empty array for empty input' do
      groups = grouper.group(items: [], max_bytes: 100, size_extractor: size_extractor)

      expect(groups).to eq([])
    end
  end

  describe '#build_group_map' do
    let(:id_extractor) { ->(item) { item[:id] } }

    specify 'maps item IDs to 1-based group indices' do
      groups = [
        [{ id: 1 }, { id: 2 }],
        [{ id: 3 }]
      ]

      group_map = grouper.build_group_map(groups: groups, id_extractor: id_extractor)

      expect(group_map[1]).to eq(1)
      expect(group_map[2]).to eq(1)
      expect(group_map[3]).to eq(2)
    end

    specify 'returns empty hash for empty groups' do
      group_map = grouper.build_group_map(groups: [], id_extractor: id_extractor)

      expect(group_map).to eq({})
    end
  end
end
