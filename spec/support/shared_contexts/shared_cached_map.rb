# !! Current setup for WebLevel1 assumes shapes are all `multi_polygon`` !!

# Usage:
#   spec/models/cached_map_spec.rb
#   spec/models/cached_map_item_spec.rb
shared_context 'cached map scenario' do

  let(:g1) { RSPEC_GEO_FACTORY.multi_polygon(
    [RSPEC_GEO_FACTORY.polygon(
      RSPEC_GEO_FACTORY.line_string(
        [RSPEC_GEO_FACTORY.point(0, 0, 0.0),
         RSPEC_GEO_FACTORY.point(0, 10, 0.0),
         RSPEC_GEO_FACTORY.point(10, 10, 0.0),
         RSPEC_GEO_FACTORY.point(10, 0, 0.0),
         RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
    )]
  ) }

  #
  # These have to overlap by at least 50% total area with g1
  #
  let(:g2) { RSPEC_GEO_FACTORY.polygon(
    RSPEC_GEO_FACTORY.line_string(
      [RSPEC_GEO_FACTORY.point(1, 1, 0.0),
       RSPEC_GEO_FACTORY.point(3, 13, 0.0),
       RSPEC_GEO_FACTORY.point(13, 13, 0.0),
       RSPEC_GEO_FACTORY.point(13, 3, 0.0),
       RSPEC_GEO_FACTORY.point(3, 3, 0.0)])
  ) }

  let(:g3) { RSPEC_GEO_FACTORY.polygon(
    RSPEC_GEO_FACTORY.line_string(
      [RSPEC_GEO_FACTORY.point(1.1, 1.0, 0.0),
       RSPEC_GEO_FACTORY.point(3, 13, 0.0),
       RSPEC_GEO_FACTORY.point(13, 13, 0.0),
       RSPEC_GEO_FACTORY.point(13, 3, 0.0),
       RSPEC_GEO_FACTORY.point(3, 3, 0.0)])
  ) }

  # A point inside both areas
  # let(:point_in) { RSPEC_GEO_FACTORY.point(5, 5, 0.0) }
  # let(:point_out) { RSPEC_GEO_FACTORY.point(20, 20, 0.0) }

  let(:gi1) { GeographicItem.create(geography: g1)}
  let(:gi2) { GeographicItem.create(geography: g2)}
  let(:gi3) { GeographicItem.create(geography: g3)}

  let(:geographic_area_type) { GeographicAreaType.create!(name: 'Country') }

  let!(:ga) { GeographicArea.create!(
    name: 'map_target',
    data_origin: 'ne_countries',
    geographic_area_type:,
    parent: FactoryBot.create(:earth_geographic_area),
    geographic_areas_geographic_items_attributes: [ { geographic_item: gi1, data_origin: 'ne_states' } ])
  }

  let!(:ga_offset) { GeographicArea.create!(
    name: 'offset 1',
    data_origin: 'foo',
    geographic_area_type:,
    parent: FactoryBot.create(:earth_geographic_area),
    geographic_areas_geographic_items_attributes: [ { geographic_item: gi2, data_origin: 'foo' } ])
  }

  let!(:ga_offset2) { GeographicArea.create!(
    name: 'offset 2',
    data_origin: 'foo',
    geographic_area_type:,
    parent: FactoryBot.create(:earth_geographic_area),
    geographic_areas_geographic_items_attributes: [ { geographic_item: gi3, data_origin: 'foo' } ])
  }

end
