require 'rails_helper'
require 'collection_layout/tree_data'

describe CollectionLayout::TreeData, type: :spinup, group: :containers do

  let(:building) { FactoryBot.create(:valid_container, type: 'Container::Building', name: 'Test Building') }

  before do
    Container.scaffold(
      building_id:  building.id,
      cabinet_type: 'cornell',
      rooms:        2,
      cabinets:     3,
      drawers:      4
    )
  end

  subject(:tree) { described_class.new(building).to_json_tree }

  # ── Top level ──────────────────────────────────────────────────────────────

  specify 'root node is the building' do
    expect(tree[:id]).to eq(building.id)
    expect(tree[:type]).to eq('Container::Building')
  end

  specify 'building node children are rooms' do
    expect(tree[:children].length).to eq(2)
    expect(tree[:children].map { |c| c[:type] }).to all(eq('Container::Room'))
  end

  specify 'building node labels are room names' do
    labels = tree[:children].map { |c| c[:name] }
    expect(labels).to all(be_present)
    expect(labels).to all(match(/Room/i))
  end

  # ── Room level ─────────────────────────────────────────────────────────────

  specify 'each room has the correct number of cabinet children' do
    tree[:children].each do |room_node|
      expect(room_node[:children].length).to eq(3)
    end
  end

  specify 'room children are cabinets' do
    tree[:children].each do |room_node|
      expect(room_node[:children].map { |c| c[:type] }).to all(eq('Container::Cabinet::Cornell'))
    end
  end

  specify 'room children labels are cabinet names' do
    tree[:children].each do |room_node|
      labels = room_node[:children].map { |c| c[:name] }
      expect(labels).to all(be_present)
      expect(labels).to all(match(/Cabinet/i))
    end
  end

  # ── Cabinet level ──────────────────────────────────────────────────────────

  specify 'each cabinet has the correct number of drawer children' do
    tree[:children].each do |room_node|
      room_node[:children].each do |cabinet_node|
        expect(cabinet_node[:children].length).to eq(4)
      end
    end
  end

  specify 'cabinet children are drawers' do
    tree[:children].each do |room_node|
      room_node[:children].each do |cabinet_node|
        expect(cabinet_node[:children].map { |c| c[:type] }).to all(eq('Container::Drawer::Cornell'))
      end
    end
  end

  specify 'cabinet children labels are drawer names' do
    tree[:children].each do |room_node|
      room_node[:children].each do |cabinet_node|
        labels = cabinet_node[:children].map { |c| c[:name] }
        expect(labels).to all(be_present)
        expect(labels).to all(match(/Drawer/i))
      end
    end
  end

  # ── Leaf level ─────────────────────────────────────────────────────────────

  specify 'drawer nodes have no children' do
    tree[:children].each do |room_node|
      room_node[:children].each do |cabinet_node|
        cabinet_node[:children].each do |drawer_node|
          expect(drawer_node[:children]).to be_empty
        end
      end
    end
  end

  specify 'only leaf (drawer) nodes carry a value' do
    tree[:children].each do |room_node|
      expect(room_node).not_to have_key(:value)
      room_node[:children].each do |cabinet_node|
        expect(cabinet_node).not_to have_key(:value)
        cabinet_node[:children].each do |drawer_node|
          expect(drawer_node[:value]).to eq(1)
        end
      end
    end
  end

  # ── Empty building ─────────────────────────────────────────────────────────

  context 'with a building that has no containers' do
    let(:empty_building) { FactoryBot.create(:valid_container, type: 'Container::Building', name: 'Empty') }

    subject(:empty_tree) { described_class.new(empty_building).to_json_tree }

    specify 'returns the building node' do
      expect(empty_tree[:id]).to eq(empty_building.id)
    end

    specify 'building has no children' do
      expect(empty_tree[:children]).to be_empty
    end
  end

end
