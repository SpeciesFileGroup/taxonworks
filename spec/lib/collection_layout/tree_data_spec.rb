require 'rails_helper'
require 'collection_layout/tree_data'

describe CollectionLayout::TreeData, type: :spinup, group: :containers do

  let(:building) { FactoryBot.create(:valid_container, type: 'Container::Building', name: 'Test Building') }

  before do
    Container.scaffold(
      building_id:  building.id,
      drawer_type: 'Container::Drawer::Cornell',
      rooms:        2,
      cabinets:     3,
      drawers:      4
    )
  end

  subject(:tree) { CollectionLayout::TreeData.new(building).to_json_tree }

  # ── Top level ──────────────────────────────────────────────────────────────

  specify 'root node is the building' do
    expect(tree[:id]).to eq(building.id)
    expect(tree[:type]).to eq('Container::Building')
  end

  specify 'building node children are rooms' do
    expect(tree[:children].length).to eq(2)
    expect(tree[:children].map { |c| c[:type] }).to eq(['Container::Room'] * 2)
  end

  specify 'building node labels are room names' do
    labels = tree[:children].map { |c| c[:name] }
    expect(labels).to eq( ['Room'] * 2)  
  end

  # ── Room level ─────────────────────────────────────────────────────────────

  specify 'room children are cabinets, and there are 3' do
    tree[:children].each do |room_node|
      expect(room_node[:children].map { |c| c[:type] }).to eq( ['Container::Cabinet'] * 3 )
    end
  end

  # ── Cabinet level ──────────────────────────────────────────────────────────

  specify 'cabinet children are drawers, and there are 4' do
    tree[:children].each do |room_node|
      room_node[:children].each do |cabinet_node|
        expect(cabinet_node[:children].map { |c| c[:type] }).to eq( ['Container::Drawer::Cornell'] * 4)
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
