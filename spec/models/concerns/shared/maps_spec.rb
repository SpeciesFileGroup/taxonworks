require 'rails_helper'

describe Shared::Maps, type: :model, group: [:geo, :cached_map] do

  include_context 'cached map scenario'

  let(:ad_offset) { FactoryBot.build( :valid_asserted_distribution, geographic_area: ga_offset) }

  specify 'Delayed::Job is cued' do
    ad_offset.save!
    expect(Delayed::Job.count).to eq(1)
  end

  specify 'Delayed::Job is cued and ran' do
    ad_offset.save!
    expect(Delayed::Worker.new.work_off).to eq [1, 0] # Returns [successes, failures]
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
      b = FactoryBot.create( :valid_asserted_distribution, otu: ad_offset.otu, geographic_area: ga_offset2)
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

  specify '.cached_map creates a CachedMap' do
    ad_offset.save!
    Delayed::Worker.new.work_off
    expect(ad_offset.otu.cached_map.persisted?).to be_truthy
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
    FactoryBot.create( :valid_asserted_distribution, otu: ad_offset.otu, geographic_area: ga_offset2)
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
