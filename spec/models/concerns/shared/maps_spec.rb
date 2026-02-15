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

  context '.create_cached_map_items with skip_register and register_queue' do
    before :each do
      ad_offset.save!
      Delayed::Worker.new.work_off
      # Clear the register created by the callback so we can test the batch path
      CachedMapRegister.delete_all
      CachedMapItem.delete_all
      CachedMapItemTranslation.delete_all
    end

    specify 'skip_register: true does not create a CachedMapRegister' do
      ad_offset.send(:create_cached_map_items, true, skip_register: true)
      expect(CachedMapRegister.count).to eq(0)
    end

    specify 'skip_register: true with register_queue appends registration hash' do
      queue = []
      ad_offset.send(:create_cached_map_items, true, skip_register: true, register_queue: queue)
      expect(queue.size).to eq(1)
      expect(queue.first[:cached_map_register_object_type]).to eq('AssertedDistribution')
      expect(queue.first[:cached_map_register_object_id]).to eq(ad_offset.id)
    end

    specify 'skip_register: true with register_queue only appends one registration per call' do
      queue = []
      ad_offset.send(:create_cached_map_items, true, skip_register: true, register_queue: queue)
      expect(queue.size).to eq(1)
    end

    specify 'queued registrations can be bulk inserted' do
      queue = []
      ad_offset.send(:create_cached_map_items, true, skip_register: true, register_queue: queue)
      expect { CachedMapRegister.insert_all(queue) }.to change(CachedMapRegister, :count).by(1)
    end

    specify 'strict translation mode logs and skips creation when translation is missing' do
      queue = []
      context = {
        otu_id: ad_offset.asserted_distribution_object_id,
        otu_taxon_name_id: ad_offset.otu.taxon_name_id,
        geographic_item_id: ad_offset.asserted_distribution_shape.default_geographic_item_id,
        geographic_area_based: true,
        require_existing_translation: true
      }

      expect {
        ad_offset.send(:create_cached_map_items, true, context:, skip_register: true, register_queue: queue)
      }.to output(/MISSING_TRANSLATION/).to_stdout

      expect(CachedMapItem.count).to eq(0)
      expect(queue).to be_empty
      expect(CachedMapRegister.count).to eq(0)
    end

    specify 'strict translation mode uses existing translation when present' do
      queue = []
      source_gi_id = ad_offset.asserted_distribution_shape.default_geographic_item_id
      translated_gi_id = ga.default_geographic_item_id

      CachedMapItemTranslation.create!(
        geographic_item_id: source_gi_id,
        translated_geographic_item_id: translated_gi_id,
        cached_map_type: 'CachedMapItem::WebLevel1'
      )

      context = {
        otu_id: ad_offset.asserted_distribution_object_id,
        otu_taxon_name_id: ad_offset.otu.taxon_name_id,
        geographic_item_id: source_gi_id,
        geographic_area_based: true,
        require_existing_translation: true
      }

      ad_offset.send(:create_cached_map_items, true, context:, skip_register: true, register_queue: queue)

      expect(CachedMapItem.count).to eq(1)
      expect(CachedMapItem.first.geographic_item_id).to eq(translated_gi_id)
      expect(queue.size).to eq(1)
      expect(CachedMapRegister.count).to eq(0)
      expect(CachedMapItemTranslation.count).to eq(1)
    end
  end

  context 'Georeference-based cached map items' do
    let(:root) { FactoryBot.create(:root_taxon_name) }
    let(:genus) { FactoryBot.create(:relationship_genus, parent: root) }
    let(:otu) { Otu.create!(taxon_name: genus) }

    let(:collecting_event) { FactoryBot.create(:valid_collecting_event) }

    let(:georeference) {
      Georeference::VerbatimData.create!(
        collecting_event:,
        geographic_item: gi2
      )
    }

    let(:specimen) {
      Specimen.create!(
        collecting_event:,
        total: 1,
      )
    }

    let!(:taxon_determination) {
      TaxonDetermination.create!(
        taxon_determination_object: specimen,
        otu:
      )
    }

    specify 'Georeference creates CachedMapItem via callback' do
      georeference
      Delayed::Worker.new.work_off
      expect(CachedMapItem.count).to eq(1)
      expect(CachedMapItem.first.otu_id).to eq(otu.id)
      expect(CachedMapItem.first.geographic_item_id).to eq(gi1.id)
    end

    specify 'Georeference creates CachedMapRegister via callback' do
      georeference
      Delayed::Worker.new.work_off
      expect(georeference.reload.cached_map_register).to be_present
    end

    context 'batch mode with context' do
      before do
        georeference
        Delayed::Worker.new.work_off
        CachedMapRegister.delete_all
        CachedMapItem.delete_all
      end

      specify 'creates CachedMapItem with pre-computed context' do
        context = {
          otu_id: [otu.id]
        }
        georeference.send(:create_cached_map_items, true, context:,
          skip_register: true, register_queue: [])
        expect(CachedMapItem.count).to eq(1)
        expect(CachedMapItem.first.geographic_item_id).to eq(gi1.id)
      end

      specify 'context with empty otu_id skips creation' do
        context = {
          otu_id: []
        }
        georeference.send(:create_cached_map_items, true, context:,
          skip_register: true, register_queue: [])
        expect(CachedMapItem.count).to eq(0)
      end
    end
  end

  context 'CachedMapItem.stubs for Georeference' do
    let(:root) { FactoryBot.create(:root_taxon_name) }
    let(:genus) { FactoryBot.create(:relationship_genus, parent: root) }
    let(:otu) { Otu.create!(taxon_name: genus) }

    let(:collecting_event) { FactoryBot.create(:valid_collecting_event) }

    let(:georeference) {
      Georeference::VerbatimData.create!(
        collecting_event:,
        geographic_item: gi2
      )
    }

    let(:specimen) {
      Specimen.create!(
        collecting_event:,
        total: 1,
      )
    }

    let!(:taxon_determination) {
      TaxonDetermination.create!(
        taxon_determination_object: specimen,
        otu:
      )
    }

    specify 'without context queries for OTUs' do
      georeference
      Delayed::Worker.new.work_off
      stubs = CachedMapItem.stubs(georeference, 'CachedMapItem::WebLevel1')
      expect(stubs[:otu_id]).to contain_exactly(otu.id)
      expect(stubs[:geographic_item_id]).to contain_exactly(gi1.id)
    end

    specify 'with pre-computed context uses provided values' do
      georeference
      Delayed::Worker.new.work_off
      context = {
        otu_id: [otu.id]
      }
      stubs = CachedMapItem.stubs(georeference, 'CachedMapItem::WebLevel1', context:)
      expect(stubs[:otu_id]).to eq([otu.id])
      expect(stubs[:geographic_item_id]).to contain_exactly(gi1.id)
    end

    specify 'with context containing multiple OTU ids' do
      otu2 = Otu.create!(taxon_name: genus)
      georeference
      Delayed::Worker.new.work_off
      context = {
        otu_id: [otu.id, otu2.id]
      }
      stubs = CachedMapItem.stubs(georeference, 'CachedMapItem::WebLevel1', context:)
      expect(stubs[:otu_id]).to contain_exactly(otu.id, otu2.id)
    end
  end
end

# class TestMaps < ApplicationRecord
#   include FakeTable
#   include Shared::Maps
# end
