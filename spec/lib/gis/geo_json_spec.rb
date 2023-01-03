require 'rails_helper'
require 'support/shared_contexts/shared_geo'
# rubocop:disable Style/StringHashKeys

describe Gis::GeoJSON, type: :model, group: [:geo, :shared_geo] do

  include_context 'stuff for complex geo tests'

  before { [gr_a, gr_b].each }

  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:source) { FactoryBot.create(:valid_source) }

  let(:linestring) {
    RSPEC_GEO_FACTORY.line_string(
        [RSPEC_GEO_FACTORY.point(0, 0, 0.0),
         RSPEC_GEO_FACTORY.point(0, 10, 0.0),
         RSPEC_GEO_FACTORY.point(10, 10, 0.0),
         RSPEC_GEO_FACTORY.point(10, 0, 0.0),
         RSPEC_GEO_FACTORY.point(0, 0, 0.0)])
  }

  let(:multipoint) { RSPEC_GEO_FACTORY.multi_point(
      [polygon_inner.points[0],
       polygon_inner.points[1],
       polygon_inner.points[2],
       polygon_inner.points[3]])
  }

  let(:multipolygon) { RSPEC_GEO_FACTORY.multi_polygon(
      [RSPEC_GEO_FACTORY.polygon(polygon_outer),
       RSPEC_GEO_FACTORY.polygon(polygon_inner)]) }

  let(:multilinestring) { RSPEC_GEO_FACTORY.multi_line_string([list_box_a, list_box_b]) }

 rlet(:polygon_outer) {
    RSPEC_GEO_FACTORY.line_string(
        [RSPEC_GEO_FACTORY.point(1, -1, 0.0),
         RSPEC_GEO_FACTORY.point(9, -1, 0.0),
         RSPEC_GEO_FACTORY.point(9, -9, 0.0),
         RSPEC_GEO_FACTORY.point(1, -9, 0.0),
         RSPEC_GEO_FACTORY.point(1, -1, 0.0)])
  }

  let(:polygon) { RSPEC_GEO_FACTORY.polygon(polygon_outer, [polygon_inner]) }

  let(:polygon_b) { FactoryBot.create(:geographic_item_polygon, polygon: polygon.as_binary, by: geo_user) }

  let(:gi_line_string) { FactoryBot.create(:geographic_item_line_string, line_string: linestring.as_binary) }

  let(:multipoint_b) { FactoryBot.create(:geographic_item_multi_point, multi_point: multipoint.as_binary) }

  let(:multilinestring_b) { FactoryBot.create(:geographic_item_multi_line_string,
                                              multi_line_string: multilinestring.as_binary) }

  let(:multipolygon_b) { FactoryBot.create(:geographic_item_multi_polygon,
                                           multi_polygon: multipolygon.as_binary,
                                           by: geo_user) }

  context "outputting GeoJSON 'Feature's" do
    let(:feature_index) { '1' }
    context 'geographic_item' do
      specify 'that a geographic_item can produce a properly formed feature' do
        object = ce_a.georeferences.first.geographic_item
        json = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'Point',
                                                              'coordinates' => [5, 5, 0] },
                                              'properties' => { 'geographic_item' => { 'id' => object.id } },
                                              'id' => feature_index.to_i }] })
      end

      specify 'that multiple features can be produced by geographic_items' do
        object_1 = ce_a.georeferences.first.geographic_item
        object_2 = ce_b.georeferences.first.geographic_item
        json = Gis::GeoJSON.feature_collection([object_1, object_2])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'Point',
                                                              'coordinates' => [5, 5, 0] },
                                              'properties' => { 'geographic_item' => { 'id' => object_1.id } },
                                              'id' => feature_index.to_i },
                                            { 'type' => 'Feature',
                                              'geometry' => { 'type' => 'Point',
                                                              'coordinates' => [5, -5, 0] },
                                              'properties' => { 'geographic_item' => { 'id' => object_2.id } },
                                              'id' => (feature_index.to_i + 1) }] })
      end

      specify "that the geographic_item type 'point' produce GeoJSON" do
        object = ce_b.georeferences.first.geographic_item
        json = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'Point',
                                                              'coordinates' => [5, -5, 0] },
                                              'properties' => { 'geographic_item' => { 'id' => object.id } },
                                              'id' => feature_index.to_i }] })
      end

      specify "that the geographic_item type 'line_string' produce GeoJSON" do
        json = Gis::GeoJSON.feature_collection([gi_line_string])
        expect(json).to eq(
                            { 'type' => 'FeatureCollection',
                              'features' => [
                                  { 'type' => 'Feature',
                                    'geometry' => { 'type' => 'LineString',
                                                    'coordinates' => [[0, 0, 0], [0, 10, 0],
                                                                      [10, 10, 0], [10, 0, 0], [0, 0, 0]] },
                                    'properties' => { 'geographic_item' => { 'id' => gi_line_string.id } },
                                    'id' => feature_index.to_i }] })
      end

      specify "that the geographic_item type 'polygon' produce GeoJSON" do
        json = Gis::GeoJSON.feature_collection([polygon_b])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'Polygon',
                                                              'coordinates' => [[[1, -1, 0], [9, -1, 0],
                                                                                 [9, -9, 0], [1, -9, 0],
                                                                                 [1, -1, 0]],
                                                                                [[2.5, -2.5, 0], [7.5, -2.5, 0],
                                                                                 [7.5, -7.5, 0], [2.5, -7.5, 0],
                                                                                 [2.5, -2.5, 0]]] },
                                              'properties' => { 'geographic_item' => { 'id' => polygon_b.id } },
                                              'id' => feature_index.to_i }] })
      end

      specify "that the geographic_item type 'multi_point' produce GeoJSON" do
        json = Gis::GeoJSON.feature_collection([multipoint_b])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'MultiPoint',
                                                              'coordinates' => [[2.5, -2.5, 0], [7.5, -2.5, 0],
                                                                                [7.5, -7.5, 0], [2.5, -7.5, 0]] },
                                              'properties' => { 'geographic_item' => { 'id' => multipoint_b.id } },
                                              'id' => feature_index.to_i }] })
      end

      specify "that the geographic_item type 'multi_line_string' produce GeoJSON" do
        json = Gis::GeoJSON.feature_collection([multilinestring_b])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'MultiLineString',
                                                              'coordinates' => [[[0, 0, 0], [0, 10, 0],
                                                                                 [10, 10, 0], [10, 0, 0], [0, 0, 0]],
                                                                                [[0, 0, 0], [10, 0, 0], [10, -10, 0],
                                                                                 [0, -10, 0], [0, 0, 0]]] },
                                              'properties' => { 'geographic_item' => { 'id' => multilinestring_b.id } },
                                              'id' => feature_index.to_i }] })
      end

      specify "that the geographic_item type 'multi_polygon' produce GeoJSON" do
        json = Gis::GeoJSON.feature_collection([multipolygon_b])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'MultiPolygon',
                                                              'coordinates' => [[[[1, -1, 0], [9, -1, 0],
                                                                                  [9, -9, 0], [1, -9, 0], [1, -1, 0]]],
                                                                                [[[2.5, -2.5, 0], [7.5, -2.5, 0],
                                                                                  [7.5, -7.5, 0], [2.5, -7.5, 0],
                                                                                  [2.5, -2.5, 0]]]] },
                                              'properties' => { 'geographic_item' => { 'id' => multipolygon_b.id } },
                                              'id' => feature_index.to_i }] })
      end

      specify "that the geographic_item type 'geometry_collection' produce GeoJSON" do
        object = GeographicItem.create!(geometry_collection: 'GEOMETRYCOLLECTION( POLYGON((0.0 0.0 0.0, ' \
                                                              '10.0 0.0 0.0, 10.0 10.0 0.0, ' \
                                                              '0.0 10.0 0.0, 0.0 0.0 0.0)), POINT(10 10 0)) ')
        json = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'GeometryCollection',
                                                              'geometries' => [{ 'type' => 'Polygon',
                                                                                 'coordinates' => [[[0, 0, 0],
                                                                                                    [10, 0, 0],
                                                                                                    [10, 10, 0],
                                                                                                    [0, 10, 0],
                                                                                                    [0, 0, 0]]] },
                                                                               { 'type' => 'Point',
                                                                                 'coordinates' => [10, 10, 0] }] },
                                              'properties' => { 'geographic_item' => { 'id' => object.id } },
                                              'id' => feature_index.to_i }] })
      end
    end

    context 'geographic_area' do
      specify 'that a geographic_area can produce a properly formed feature' do
        object = ce_a.geographic_area
        json = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'MultiPolygon',
                                                              'coordinates' => [[[[0, 0, 0], [0, 10, 0],
                                                                                  [10, 10, 0], [10, 0, 0],
                                                                                  [0, 0, 0]]]] },
                                              'properties' => { 'geographic_area' => { 'id' => object.id,
                                                                                       'tag' => 'A' } },
                                              'id' => feature_index.to_i }] })
      end
    end

    context 'georeference' do
      specify 'that a georeference can produce a properly formed feature' do
        object = ce_a.georeferences.first
        json = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'Point',
                                                              'coordinates' => [5, 5, 0.0] },
                                              'properties' => { 'georeference' =>
                                                                    { 'id' => object.id,
                                                                      'tag' => "Georeference ID = #{object.id}" } },
                                              'id' => feature_index.to_i }] })
      end
    end

    context 'collecting_event' do
      specify 'that a collecting_event can produce a properly formed feature' do
        object = ce_a
        json = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'Point',
                                                              'coordinates' => [5, 5, 0] },
                                              'properties' => { 'collecting_event' =>
                                                                    { 'id' => object.id,
                                                                      'tag' => "Collecting event #{ce_a.id}." } },
                                              'id' => feature_index.to_i }] })
      end
    end

    context 'asserted_distribution' do
      let(:feature_index) { '1' }
      specify 'that an asserted_distribution can produce a properly formed feature' do
        point = ce_b.georeferences.first.geographic_item.geo_object
        geographic_areas = GeographicArea.find_by_lat_long(point.y, point.x).order('geographic_areas.name ASC')
        # puts geographic_areas.map(&:name)
        # To fix: provide a geographic area array for below
        objects = AssertedDistribution.stub_new({ 'otu_id' => otu.id,
                                                  'source_id' => source.id,
                                                  'geographic_areas' => geographic_areas })
        objects.map(&:save!)
        json = Gis::GeoJSON.feature_collection(objects)
        expect(json).to eq({ 'type' => 'FeatureCollection',
                             'features' => [{ 'type' => 'Feature',
                                              'geometry' => { 'type' => 'MultiPolygon',
                                                              'coordinates' => [[[[0.0, 0.0, 0.0], [10.0, 0.0, 0.0],
                                                                                  [10.0, -10.0, 0.0], [0.0, -10.0, 0.0],
                                                                                  [0.0, 0.0, 0.0]]]] },
                                              'properties' => { 'asserted_distribution' => { 'id' => objects[0].id } },
                                              'id' => (feature_index.to_i + 0) },
                                            { 'type' => 'Feature',
                                              'geometry' => { 'type' => 'MultiPolygon',
                                                              'coordinates' => [[[[0.0, 10.0, 0.0], [10.0, 10.0, 0.0],
                                                                                  [10.0, -10.0, 0.0], [0.0, -10.0, 0.0],
                                                                                  [0.0, 10.0, 0.0]]]] },
                                              'properties' => { 'asserted_distribution' => { 'id' => objects[1].id } },
                                              'id' => (feature_index.to_i + 1) }] })
      end
    end
  end

  context 'collecting_event, geographic_area, georeference, geographic_item' do
    let(:feature_index) { '1' }
    specify 'that feature_collection can take an array of types of objects' do
      objects = [ce_a, area_b, ce_b.georeferences.first, ce_b.georeferences.first.geographic_item]
      json = Gis::GeoJSON.feature_collection(objects)
      expect(json).to eq({ 'type' => 'FeatureCollection',
                           'features' => [{ 'type' => 'Feature',
                                            'properties' => { 'collecting_event' =>
                                                                  { 'id' => ce_a.id,
                                                                    'tag' => "Collecting event #{ce_a.id}." } },
                                            'geometry' => { 'type' => 'Point',
                                                            'coordinates' => [5, 5, 0] },
                                            'id' => (feature_index.to_i + 0) },
                                          { 'type' => 'Feature',
                                            'properties' => { 'geographic_area' => { 'id' => area_b.id,
                                                                                     'tag' => area_b.name } },
                                            'geometry' => { 'type' => 'MultiPolygon',
                                                            'coordinates' => [[[[0, 0, 0], [10, 0, 0],
                                                                                [10, -10, 0], [0, -10, 0],
                                                                                [0, 0, 0]]]] },
                                            'id' => (feature_index.to_i + 1) },
                                          { 'type' => 'Feature',
                                            'geometry' => { 'type' => 'Point',
                                                            'coordinates' => [5.0, -5.0, 0.0] },
                                            'properties' => { 'georeference' => { 'id' => ce_b.georeferences.first.id,
                                                                                  'tag' => 'Georeference ID = ' \
                                                                              "#{ce_b.georeferences.first.id}" } },
                                            'id' => (feature_index.to_i + 2) },
                                          { 'type' => 'Feature',
                                            'geometry' => { 'type' => 'Point',
                                                            'coordinates' => [5, -5, 0] },
                                            'properties' => { 'geographic_item' => { 'id' => ce_b.georeferences.first
                                                                                                 .geographic_item.id } },
                                            'id' => (feature_index.to_i + 3) }] })
    end
  end
end
# rubocop:enable Style/StringHashKeys
