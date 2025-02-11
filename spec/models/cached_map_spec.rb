require 'rails_helper'

RSpec.describe CachedMap, type: :model, group: [:geo, :cached_map] do

  include_context 'cached map scenario'

  let(:cached_map) { CachedMap.new }

  let(:map_json) { '{"type": "Polygon", "coordinates": [[[14.67292, 13.034527, 0], [14.67292, 18.27943, 0], [21.70636, 18.27943, 0], [21.70636, 13.034527, 0], [14.67292, 13.034527, 0]]]}' }

  specify '#geo_json_string 1' do
    cached_map.geo_json_string = map_json
    expect(cached_map.geometry).to be_truthy
  end

  specify '#geo_json_string 2' do
    m = CachedMap.new(geo_json_string: map_json)
    expect(m.geometry).to be_truthy
  end

  specify 'Factory test' do
    expect(FactoryBot.create(:valid_cached_map)).to be_truthy
  end

  context '#synced?' do
    let(:otu) { FactoryBot.create(:valid_otu) }

    let(:ad) {
      AssertedDistribution.create!(
        otu:,
        geographic_area: ga,
        source: FactoryBot.create(:valid_source)
      )
    }

    let(:ad_ref_count) {
      # Using ga_offset here in addition to ga on ad causes the refcount on the
      # cmi from ad to be incremented.
      AssertedDistribution.create!(
        otu:,
        geographic_area: ga_offset,
        source: FactoryBot.create(:valid_source)
      )
    }

    let(:ad_new_cmi) {
      ga_new_cmi = GeographicArea.create!(
        name: 'map_target2',
        data_origin: 'ne_countries',
        parent: FactoryBot.create(:earth_geographic_area),
        geographic_area_type:,
        geographic_areas_geographic_items_attributes:
          [ { geographic_item: gi2, data_origin: 'ne_states' } ]
      )

      # Using ga2 here in addition to ga on ad causes a second CachedMapItem to
      # be created (as opposed to the ref count on the first one being
      # incremented).
      AssertedDistribution.create!(
        otu:,
        geographic_area: ga_new_cmi,
        source: FactoryBot.create(:valid_source)
      )
    }

    specify 'new cached_maps are synced' do
      [ad, ad_ref_count, ad_new_cmi] # instantiate
      Delayed::Worker.new.work_off
      expect(otu.cached_map.synced?).to be_truthy
    end

    specify 'new asserted distribution makes cached_map not synced 1' do
      ad
      Delayed::Worker.new.work_off
      otu.cached_map

      ad_ref_count
      Delayed::Worker.new.work_off

      expect(otu.cached_map.synced?).to be_falsey
    end

    specify 'new asserted distribution makes cached_map not synced 2' do
      ad
      Delayed::Worker.new.work_off
      otu.cached_map

      ad_new_cmi
      Delayed::Worker.new.work_off

      expect(otu.cached_map.synced?).to be_falsey
    end
  end
end
