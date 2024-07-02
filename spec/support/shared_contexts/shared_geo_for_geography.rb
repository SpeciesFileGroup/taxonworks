require 'support/vendor/rspec_geo_helpers'

RSPEC_GEO_FACTORY = Gis::FACTORY

shared_context 'stuff for geography tests' do

  let(:simple_shapes) { {
    point: 'POINT(10 -10 0)',
    line_string: 'LINESTRING(0.0 0.0 0.0, 10.0 0.0 0.0)',
    polygon:'POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0))',
    multi_point: 'MULTIPOINT((10.0 10.0 0.0), (20.0 20.0 0.0))',
    multi_line_string: 'MULTILINESTRING((0.0 0.0 0.0, 10.0 0.0 0.0), (20.0 0.0 0.0, 30.0 0.0 0.0))',
    multi_polygon: 'MULTIPOLYGON(((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, ' \
    '0.0 0.0 0.0)),((10.0 10.0 0.0, 20.0 10.0 0.0, 20.0 20.0 0.0, 10.0 20.0 0.0, 10.0 10.0 0.0)))',
    geometry_collection: 'GEOMETRYCOLLECTION( POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, ' \
    '0.0 10.0 0.0, 0.0 0.0 0.0)), POINT(10 10 0)) ',
    geography:'POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0))'
  }.freeze }

  let(:simple_point) {
    FactoryBot.create(:geographic_item_geography, geography: simple_shapes[:point])
  }

  let(:simple_line_string) {
    FactoryBot.create(:geographic_item_geography, geography: simple_shapes[:line_string])
  }

  let(:simple_polygon) {
    FactoryBot.create(:geographic_item_geography, geography: simple_shapes[:polygon])
  }

  let(:simple_multi_point) {
    FactoryBot.create(:geographic_item_geography, geography: simple_shapes[:multi_point])
  }

  let(:simple_multi_line_string) {
    FactoryBot.create(:geographic_item_geography, geography: simple_shapes[:multi_line_string])
  }

  let(:simple_multi_polygon) {
    FactoryBot.create(
      :geographic_item_geography, geography: simple_shapes[:multi_polygon]
    )
  }

  let(:simple_geometry_collection) {
    FactoryBot.create(
      :geographic_item_geography, geography: simple_shapes[:geometry_collection]
    )
  }

  let(:simple_rgeo_point) { RSPEC_GEO_FACTORY.point(10, -10, 0) }
end