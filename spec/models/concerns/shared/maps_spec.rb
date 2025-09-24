require 'rails_helper'

describe Shared::Maps, type: :model, group: [:geo, :cached_map] do

  include_context 'cached map scenario'

  let(:ad_offset) { FactoryBot.build(:valid_otu_asserted_distribution,
    asserted_distribution_object: Otu.new(taxon_name: FactoryBot.create(:relationship_genus, parent: FactoryBot.create(:root_taxon_name))),
    asserted_distribution_shape: ga_offset)
  }


  # Must turn back on the after_destroy in the maps.concern to revisit these.

  xspecify '#destroy_cached_map' do
    ad_offset.save!
    Delayed::Worker.new.work_off # triggers cached map item build
    expect(ad_offset.otu.cached_map).to be_truthy

    a = FactoryBot.create(:valid_otu_asserted_distribution, asserted_distribution_object: ad_offset.otu)
    Delayed::Worker.new.work_off # triggers cached map destroy

    expect(ad_offset.otu.cached_maps).to be_empty
  end

  xspecify 'Delayed::Job is cued' do
    ad_offset.save!
    expect(Delayed::Job.count).to eq(2) # Create items, clear CachedMap
  end

  xspecify 'Delayed::Job is cued and ran' do
    ad_offset.save!
    expect(Delayed::Worker.new.work_off).to eq [2, 0] # Returns [successes, failures]
  end

  specify '.cached_map creates a CachedMap' do
    ad_offset.save!
    Delayed::Worker.new.work_off
    expect(ad_offset.otu.cached_map.persisted?).to be_truthy
  end

  specify '#touched_cached_maps' do
    ad_offset.save!
    expect(ad_offset.send(:touched_cached_maps).pluck(:id)).to eq([ad_offset.asserted_distribution_object_id])
  end

  specify '#touched_cached_maps (untouched)' do
    ad_offset.save!
    p = FactoryBot.create(:valid_project)
    proot = Protonym.where(name: 'Root', project: p).first
    pspecies = FactoryBot.create(:relationship_species, parent: proot, project: p)
    potu = FactoryBot.create(:valid_otu, project: p, taxon_name: pspecies)
    a = FactoryBot.create(:valid_otu_asserted_distribution,
      asserted_distribution_object: potu,
      asserted_distribution_shape: ga_offset)

    Delayed::Worker.new.work_off

    expect(ad_offset.send(:touched_cached_maps).map(&:id)).to contain_exactly(ad_offset.asserted_distribution_object_id)
  end

  specify '#cached_maps_to_clear 1' do
    ad_offset.save!
    p = FactoryBot.create(:valid_project)
    potu = FactoryBot.create(:valid_otu, project: p)
    a = FactoryBot.create(:valid_otu_asserted_distribution,
      asserted_distribution_object: potu,
      asserted_distribution_shape: ga_offset)
    Delayed::Worker.new.work_off

    expect(ad_offset.send(:cached_maps_to_clear).all).to eq([])
  end

  specify '#cached_maps_to_clear 2' do
    ad_offset.save!
    p = FactoryBot.create(:valid_project)
    potu = FactoryBot.create(:valid_otu, project: p)
    a = FactoryBot.create(:valid_otu_asserted_distribution,
      asserted_distribution_object: potu,
      asserted_distribution_shape: ga_offset)
    Delayed::Worker.new.work_off

    a.asserted_distribution_object.cached_map
    ad_offset.asserted_distribution_object.cached_map
    Delayed::Worker.new.work_off

    expect(ad_offset.send(:cached_maps_to_clear).all).to eq([ad_offset.otu.cached_map])
  end

  context 'Delayed::Job(s) on create' do
    before do
      ad_offset.save!
      Delayed::Worker.new.work_off
    end

    specify 'CachedMapItem(s)' do
      expect(CachedMapItem.count).to eq(1)
    end

    specify 'CachedMapTranslation' do
      expect(CachedMapItemTranslation.count).to eq(1)
    end

    specify 'CachedMapRegister' do
      expect(CachedMapRegister.count).to eq(1)
    end

    specify 'CachedMapRegister can be ' do
      expect(ad_offset.cached_map_register.present?).to be_truthy
    end
  end

  context 'Delayed::Job(s) on destroy' do
    before do
      ad_offset.save!
      Delayed::Worker.new.work_off
    end

    specify 'removes from CachedMapRegister' do
      ad_offset.destroy!
      Delayed::Worker.new.work_off
      expect(CachedMapRegister.count).to eq(0)
    end

    specify 'removes CachedMapItem when no more references' do
      ad_offset.run_callbacks(:destroy)
      Delayed::Worker.new.work_off
      expect(CachedMapItem.count).to eq(0)
    end

    specify 'decrements CachedMapItem reference_count' do
      b = FactoryBot.create( :valid_otu_asserted_distribution, asserted_distribution_object: ad_offset.otu, asserted_distribution_shape: ga_offset2)
      Delayed::Worker.new.work_off

      expect(b.otu.cached_map_items.count).to eq(1)
      expect(b.otu.cached_map_items.first.reference_count).to eq(2)

      ad_offset.run_callbacks(:destroy)
      Delayed::Worker.new.work_off

      expect(b.otu.cached_map_items.first.reference_count).to eq(1)
    end

    specify 'decrements CachedMapItem reference count 2' do
      # Hack the total
      ad_offset.otu.cached_map_items.first.update_column(:reference_count, 99)

      ad_offset.run_callbacks(:destroy)
      Delayed::Worker.new.work_off

      expect(CachedMapItem.first.reload.reference_count).to eq(98)
    end
  end

  specify '.cached_map_items_to_clean' do
    ad_offset.save!
    Delayed::Worker.new.work_off
    a = ad_offset.cached_map_items_to_clean
    expect(a.first).to eq(CachedMapItem.first)
  end

  specify 'Delayed::Job increments map when > 1 reference' do
    ad_offset.save!
    Delayed::Worker.new.work_off
    FactoryBot.create( :valid_otu_asserted_distribution, asserted_distribution_object: ad_offset.otu, asserted_distribution_shape: ga_offset2)
    Delayed::Worker.new.work_off
    expect(ad_offset.otu.cached_map.reload.reference_count).to eq(2)
  end

  context '.create_cached_map_items' do
    before :each do
      ad_offset.save!
      ad_offset.send(:create_cached_map_items)
    end

    specify 'registers' do
      expect(ad_offset.cached_map_register.present?).to be_truthy
    end

    specify 'creates items' do
      expect(ad_offset.otu.cached_map_items.count).to eq(1)
    end

    specify 'creates translations ' do
      expect(CachedMapItemTranslation.count).to eq(1)
    end
  end
end

# class TestMaps < ApplicationRecord
#   include FakeTable
#   include Shared::Maps
# end
