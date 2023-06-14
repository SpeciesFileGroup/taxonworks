require 'rails_helper'

describe 'Maps', type: :model, group: [:geo] do

  let(:g1) { RSPEC_GEO_FACTORY.polygon(
    RSPEC_GEO_FACTORY.line_string(
      [RSPEC_GEO_FACTORY.point(0, 0, 0.0),
       RSPEC_GEO_FACTORY.point(0, 10, 0.0),
       RSPEC_GEO_FACTORY.point(10, 10, 0.0),
       RSPEC_GEO_FACTORY.point(10, 0, 0.0),
       RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
  )
  }

  let(:g2) { RSPEC_GEO_FACTORY.polygon(
    RSPEC_GEO_FACTORY.line_string(
      [RSPEC_GEO_FACTORY.point(3, 3, 0.0),
       RSPEC_GEO_FACTORY.point(3, 13, 0.0),
       RSPEC_GEO_FACTORY.point(13, 13, 0.0),
       RSPEC_GEO_FACTORY.point(13, 3, 0.0),
       RSPEC_GEO_FACTORY.point(3, 3, 0.0)])
  )
  }

  # A point inside both areas
  let(:point_in) { RSPEC_GEO_FACTORY.point(5, 5, 0.0) }
  let(:point_out) { RSPEC_GEO_FACTORY.point(20, 20, 0.0) }

  let(:gi1) { GeographicItem.create(polygon: g1)}
  let(:gi2) { GeographicItem.create(polygon: g1)}

  let(:geographic_area_type) { GeographicAreaType.create!(name: 'Country') }

  let!(:ga) { GeographicArea.create!(
    name: 'map_target',
    data_origin: 'ne_countries',
    geographic_area_type:,
    parent: FactoryBot.create(:earth_geographic_area),
    geographic_areas_geographic_items_attributes: [ { geographic_item: gi1, data_origin: 'ne_countries' } ])
  }

  let!(:ga_offset) { GeographicArea.create!(
    name: 'offset',
    data_origin: 'foo',
    geographic_area_type:,
    parent: FactoryBot.create(:earth_geographic_area),
    geographic_areas_geographic_items_attributes: [ { geographic_item: gi2, data_origin: 'foo' } ])
  }

  let(:ad_offset) { FactoryBot.build( :valid_asserted_distribution, geographic_area: ga_offset) }

  specify 'delayed job is cued and ran' do
    ad_offset.save!
    expect(Delayed::Worker.new.work_off).to eq [1, 0] # Returns [successes, failures]
  end

  specify 'delayed job is cued' do
    ad_offset.save!
    expect(Delayed::Job.count).to eq(1)
  end

  specify 'cached_map_items are created' do
    ad_offset.save!
    expect(Delayed::Worker.new.work_off).to eq [1, 0] # Returns [successes, failures]
  end

  specify 'delayed job registers' do
    ad_offset.save!
    Delayed::Worker.new.work_off
    expect(ad_offset.cached_map_register.present?).to be_truthy
  end

  specify 'cached_map_items are created' do
    ad_offset.save!
    Delayed::Worker.new.work_off
    expect(ad_offset.cached_map_register.present?).to be_truthy
  end

  specify 'translation is created' do
    ad_offset.save!
    Delayed::Worker.new.work_off
    expect(CachedMapItemTranslation.count).to eq(1)
  end

  # does not involve DelayedJob
  context '#create_cached_map_items' do
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

class TestMaps < ApplicationRecord
  include FakeTable
  include Shared::Maps
end
