require 'rails_helper'

# Uses type: model to set $user_id and $project_id, this should be
# deprecated eventually.
describe Gis::GeoJSON, group: :geo, type: :model do

  let(:otu) { FactoryGirl.create(:valid_otu) }
  let(:source) { FactoryGirl.create(:valid_source) }

  before(:all) { 
    generate_political_areas_with_collecting_events
    generate_geo_test_objects
  }

  after(:all) {
   clean_slate_geo
  }

  context "outputting GeoJSON 'Feature's" do
    let(:feature_index) { '1' }
    context 'geographic_item' do
      specify 'that a geographic_item can produce a properly formed feature' do
        # pending
        object = @ce_p1.georeferences.first.geographic_item
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'Point',
                                                             'coordinates' => [36.5, 27.5, 0]},
                                            'properties' => {'geographic_item' => {'id' => object.id}},
                                            'id'         => feature_index.to_i}]})
      end

      specify 'that multiple features can be produced by geographic_items' do
        object_1 = @ce_p1.georeferences.first.geographic_item
        object_2 = @ce_old_boxia_2.georeferences.first.geographic_item
        json     = Gis::GeoJSON.feature_collection([object_1, object_2])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'Point',
                                                             'coordinates' => [36.5, 27.5, 0]},
                                            'properties' => {'geographic_item' => {'id' => object_1.id}},
                                            'id'         => feature_index.to_i},
                                           {'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'Point',
                                                             'coordinates' => [34.5, 25.5, 0]},
                                            'properties' => {'geographic_item' => {'id' => object_2.id}},
                                            'id'         => (feature_index.to_i + 1)}]})
      end

      specify "that the geographic_item type 'point' produce GeoJSON" do
        object = @ce_p1.georeferences.first.geographic_item
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'Point',
                                                             'coordinates' => [36.5, 27.5, 0]},
                                            'properties' => {'geographic_item' => {'id' => object.id}},
                                            'id'         => feature_index.to_i}]})
      end

      specify "that the geographic_item type 'line_string' produce GeoJSON" do
        object = @a
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'LineString',
                                                             'coordinates' => [[-32, 21, 0], [-25, 21, 0], [-25, 16, 0], [-21, 20, 0]]},
                                            'properties' => {'geographic_item' => {'id' => object.id}},
                                            'id'         => feature_index.to_i}]})
      end

      specify "that the geographic_item type 'polygon' produce GeoJSON" do
        object = @b
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'Polygon',
                                                             'coordinates' => [[[-14, 23, 0], [-14, 11, 0], [-2, 11, 0], [-2, 23, 0], [-8, 21, 0], [-14, 23, 0]], [[-11, 18, 0], [-8, 17, 0], [-6, 20, 0], [-4, 16, 0], [-7, 13, 0], [-11, 14, 0], [-11, 18, 0]]]},
                                            'properties' => {'geographic_item' => {'id' => object.id}},
                                            'id'         => feature_index.to_i}]})
      end

      specify "that the geographic_item type 'multi_point' produce GeoJSON" do
        object = @h
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'MultiPoint',
                                                             'coordinates' => [[3, -14, 0], [6, -12.9, 0], [5, -16, 0], [4, -17.9, 0], [7, -17.9, 0]]},
                                            'properties' => {'geographic_item' => {'id' => object.id}},
                                            'id'         => feature_index.to_i}]})
      end

      specify "that the geographic_item type 'multi_line_string' produce GeoJSON" do
        object = @c
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'MultiLineString',
                                                             'coordinates' => [[[23, 21, 0], [16, 21, 0], [16, 16, 0], [11, 20, 0]], [[4, 12.6, 0], [16, 12.6, 0], [16, 7.6, 0]], [[21, 12.6, 0], [26, 12.6, 0], [22, 17.6, 0]]]},
                                            'properties' => {'geographic_item' => {'id' => object.id}},
                                            'id'         => feature_index.to_i}]})
      end

      specify "that the geographic_item type 'multi_polygon' produce GeoJSON" do
        object = @g
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'MultiPolygon',
                                                             'coordinates' => [[[[28, 2.3, 0], [23, -1.7, 0], [26, -4.8, 0], [28, 2.3, 0]]], [[[22, -6.8, 0], [22, -9.8, 0], [16, -6.8, 0], [22, -6.8, 0]]], [[[16, 2.3, 0], [14, -2.8, 0], [18, -2.8, 0], [16, 2.3, 0]]]]},
                                            'properties' => {'geographic_item' => {'id' => object.id}},
                                            'id'         => feature_index.to_i}]})
      end

      specify "that the geographic_item type 'geometry_collection' produce GeoJSON" do
        object = GeographicItem.create(geometry_collection: SIMPLE_SHAPES[:geometry_collection])
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'       => 'GeometryCollection',
                                                             'geometries' => [{'type'        => 'Polygon',
                                                                               'coordinates' => [[[0, 0, 0], [10, 0, 0], [10, 10, 0], [0, 10, 0], [0, 0, 0]]]},
                                                                              {'type'        => 'Point',
                                                                               'coordinates' => [10, 10, 0]}]},
                                            'properties' => {'geographic_item' => {'id' => object.id}},
                                            'id'         => feature_index.to_i}]})
      end
    end

    context 'geographic_area' do
      specify 'that a geographic_area can produce a properly formed feature' do
        object = @ce_p1.geographic_area
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'MultiPolygon',
                                                             'coordinates' => [[[[36, 28, 0], [37, 28, 0], [37, 27, 0], [36, 27, 0], [36, 28, 0]]]]},
                                            'properties' => {'geographic_area' => {'id' => object.id,
                                                                                   'tag' => 'P1'}},
                                            'id'         => feature_index.to_i}]})
      end
    end

    context 'georeference' do
      specify 'that a georeference can produce a properly formed feature' do
        object = @ce_p1.georeferences.first
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'Point',
                                                             'coordinates' => [36.5, 27.5, 0.0]},
                                            'properties' => {'georeference' => {'id' => object.id}},
                                            'id'         => feature_index.to_i}]})
      end
    end

    context 'collecting_event' do
      specify 'that a collecting_event can produce a properly formed feature' do
        object = @ce_p1
        json   = Gis::GeoJSON.feature_collection([object])
        expect(json).to eq({'type'     => 'FeatureCollection',
                            'features' => [{'type'       => 'Feature',
                                            'geometry'   => {'type'        => 'Point',
                                                             'coordinates' => [36.5, 27.5, 0]},
                                            'properties' => {'collecting_event' => {'id' => object.id, 'tag' => 'NoName'}},
                                            'id'         => feature_index.to_i}]})
      end
    end

    context 'asserted_distribution' do
      let(:feature_index) { '1' }
      specify 'that an asserted_distribution can produce a properly formed feature' do
        point            = @gr_n3_ob.geographic_item.geo_object
        geographic_areas = GeographicArea.find_by_lat_long(point.y, point.x).order('geographic_areas.name ASC')
        # puts geographic_areas.map(&:name)
# To fix: provide a geographic area array for below
        objects          = AssertedDistribution.stub_new({'otu_id'           => otu.id,
                                                          'source_id'        => source.id,
                                                          'geographic_areas' => geographic_areas})
        objects.map(&:save!)
        json = Gis::GeoJSON.feature_collection(objects)
        expect(json).to eq({"type"     => "FeatureCollection",
                            "features" => [{"type"       => "Feature",
                                            "geometry"   => {"type"        => "MultiPolygon",
                                                             "coordinates" => [[[[33.0, 28.0, 0.0], [37.0, 28.0, 0.0], [37.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 28.0, 0.0]]]]},
                                            "properties" => {"asserted_distribution" => {"id" => objects[0].id}},
                                            "id"         => (feature_index.to_i + 0)},
                                           {"type"       => "Feature",
                                            "geometry"   => {"type"        => "MultiPolygon",
                                                             "coordinates" => [[[[34.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 25.0, 0.0], [34.0, 25.0, 0.0], [34.0, 26.0, 0.0]]]]},
                                            "properties" => {"asserted_distribution" => {"id" => objects[1].id}},
                                            "id"         => (feature_index.to_i + 1)},
                                           {"type"       => "Feature",
                                            "geometry"   => {"type"        => "MultiPolygon",
                                                             "coordinates" => [[[[33.0, 28.0, 0.0], [35.0, 28.0, 0.0], [35.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 28.0, 0.0]]]]},
                                            "properties" => {"asserted_distribution" => {"id" => objects[2].id}},
                                            "id"         => (feature_index.to_i + 2)},
                                           {"type"       => "Feature",
                                            "geometry"   => {"type"        => "MultiPolygon",
                                                             "coordinates" => [[[[33.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 26.0, 0.0]]]]},
                                            "properties" => {"asserted_distribution" => {"id" => objects[3].id}},
                                            "id"         => (feature_index.to_i + 3)},
                                           {"type"       => "Feature",
                                            "geometry"   => {"type"        => "MultiPolygon",
                                                             "coordinates" => [[[[34.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 25.0, 0.0], [34.0, 25.0, 0.0], [34.0, 26.0, 0.0]]]]},
                                            "properties" => {"asserted_distribution" => {"id" => objects[4].id}},
                                            "id"         => (feature_index.to_i + 4)}]})
        # todo: consider this to be another strange case of object order displacement
        # expect(json).to eq({"type"     => "FeatureCollection",
        #                     "features" => [{"type"       => "Feature",
        #                                     "geometry"   => {"type"        => "MultiPolygon",
        #                                                      "coordinates" => [[[[33.0, 28.0, 0.0], [37.0, 28.0, 0.0], [37.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 28.0, 0.0]]]]},
        #                                     "properties" => {"asserted_distribution" => {"id" => objects[0].id}},
        #                                     "id"         => (feature_index.to_i + 0)},
        #                                    {"type"       => "Feature",
        #                                     "geometry"   => {"type"        => "MultiPolygon",
        #                                                      "coordinates" => [[[[33.0, 28.0, 0.0], [35.0, 28.0, 0.0], [35.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 28.0, 0.0]]]]},
        #                                     "properties" => {"asserted_distribution" => {"id" => objects[1].id}},
        #                                     "id"         => (feature_index.to_i + 1)},
        #                                    {"type"       => "Feature",
        #                                     "geometry"   => {"type"        => "MultiPolygon",
        #                                                      "coordinates" => [[[[33.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 26.0, 0.0]]]]},
        #                                     "properties" => {"asserted_distribution" => {"id" => objects[2].id}},
        #                                     "id"         => (feature_index.to_i + 2)},
        #                                    {"type"       => "Feature",
        #                                     "geometry"   => {"type"        => "MultiPolygon",
        #                                                      "coordinates" => [[[[34.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 25.0, 0.0], [34.0, 25.0, 0.0], [34.0, 26.0, 0.0]]]]},
        #                                     "properties" => {"asserted_distribution" => {"id" => objects[3].id}},
        #                                     "id"         => (feature_index.to_i + 3)},
        #                                    {"type"       => "Feature",
        #                                     "geometry"   => {"type"        => "MultiPolygon",
        #                                                      "coordinates" => [[[[34.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 25.0, 0.0], [34.0, 25.0, 0.0], [34.0, 26.0, 0.0]]]]},
        #                                     "properties" => {"asserted_distribution" => {"id" => objects[4].id}},
        #                                     "id"         => (feature_index.to_i + 4)}]})
        # expect(json).to eq({"type"     => "FeatureCollection",
        #                     "features" => [{"type"       => "Feature",
        #                                     "geometry"   => {"type"        => "MultiPolygon",
        #                                                      "coordinates" => [[[[34.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 25.0, 0.0], [34.0, 25.0, 0.0], [34.0, 26.0, 0.0]]]]},
        #                                     "properties" => {"asserted_distribution" => {"id" => objects[0].id}},
        #                                     "id"         => (feature_index.to_i + 0)},
        #                                    {"type"       => "Feature",
        #                                     "geometry"   => {"type"        => "MultiPolygon",
        #                                                      "coordinates" => [[[[34.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 25.0, 0.0], [34.0, 25.0, 0.0], [34.0, 26.0, 0.0]]]]},
        #                                     "properties" => {"asserted_distribution" => {"id" => objects[1].id}},
        #                                     "id"         => (feature_index.to_i + 1)},
        #                                    {"type"       => "Feature",
        #                                     "geometry"   => {"type"        => "MultiPolygon",
        #                                                      "coordinates" => [[[[33.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 26.0, 0.0]]]]},
        #                                     "properties" => {"asserted_distribution" => {"id" => objects[2].id}},
        #                                     "id"         => (feature_index.to_i + 2)},
        #                                    {"type"       => "Feature",
        #                                     "geometry"   => {"type"        => "MultiPolygon",
        #                                                      "coordinates" => [[[[33.0, 28.0, 0.0], [35.0, 28.0, 0.0], [35.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 28.0, 0.0]]]]},
        #                                     "properties" => {"asserted_distribution" => {"id" => objects[3].id}},
        #                                     "id"         => (feature_index.to_i + 3)},
        #                                    {"type"       => "Feature",
        #                                     "geometry"   => {"type"        => "MultiPolygon",
        #                                                      "coordinates" => [[[[33.0, 28.0, 0.0], [37.0, 28.0, 0.0], [37.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 28.0, 0.0]]]]},
        #                                     "properties" => {"asserted_distribution" => {"id" => objects[4].id}},
        #                                     "id"         => (feature_index.to_i + 4)}]})
        # OR
        # expect(json).to eq({'type'     => 'FeatureCollection',
        #                     'features' => [{'type'       => 'Feature',
        #                                     'geometry'   => {'type'        => 'MultiPolygon',
        #                                                      'coordinates' => [[[[33.0, 28.0, 0.0], [37.0, 28.0, 0.0], [37.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 28.0, 0.0]]]]},
        #                                     'properties' => {'asserted_distribution' => {'id' => objects[0].id}},
        #                                     'id'         => (feature_index.to_i + 0)},
        #                                    {'type'       => 'Feature',
        #                                     'geometry'   => {'type'        => 'MultiPolygon',
        #                                                      'coordinates' => [[[[33.0, 28.0, 0.0], [35.0, 28.0, 0.0], [35.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 28.0, 0.0]]]]},
        #                                     'properties' => {'asserted_distribution' => {'id' => objects[1].id}},
        #                                     'id'         => (feature_index.to_i + 1)},
        #                                    {'type'       => 'Feature',
        #                                     'geometry'   => {'type'        => 'MultiPolygon',
        #                                                      'coordinates' => [[[[33.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 24.0, 0.0], [33.0, 24.0, 0.0], [33.0, 26.0, 0.0]]]]},
        #                                     'properties' => {'asserted_distribution' => {'id' => objects[2].id}},
        #                                     'id'         => (feature_index.to_i + 2)},
        #                                    {'type'       => 'Feature',
        #                                     'geometry'   => {'type'        => 'MultiPolygon',
        #                                                      'coordinates' => [[[[34.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 25.0, 0.0], [34.0, 25.0, 0.0], [34.0, 26.0, 0.0]]]]},
        #                                     'properties' => {'asserted_distribution' => {'id' => objects[3].id}},
        #                                     'id'         => (feature_index.to_i + 3)},
        #                                    {'type'       => 'Feature',
        #                                     'geometry'   => {'type'        => 'MultiPolygon',
        #                                                      'coordinates' => [[[[34.0, 26.0, 0.0], [35.0, 26.0, 0.0], [35.0, 25.0, 0.0], [34.0, 25.0, 0.0], [34.0, 26.0, 0.0]]]]},
        #                                     'properties' => {'asserted_distribution' => {'id' => objects[4].id}},
        #                                     'id'         => (feature_index.to_i + 4)}]})
      end
    end
  end

  context 'collecting_event, geographic_area, georeference, geographic_item' do
    let(:feature_index) { '1' }
    specify 'that feature_collection can take an array of types of objects' do
      objects = [@ce_old_boxia_2, @area_q, @gr_m4, @item_p4]
      json    = Gis::GeoJSON.feature_collection(objects)
      expect(json).to eq({'type'     => 'FeatureCollection',
                          'features' => [{'type'       => 'Feature',
                                          'geometry'   => {'type'        => 'Point',
                                                           'coordinates' => [34.5, 25.5, 0]},
                                          'properties' => {'collecting_event' => {'id' => objects[0].id,
                                                                                  'tag' => 'NoName'}},
                                          'id'         => (feature_index.to_i + 0)},
                                         {'type'       => 'Feature',
                                          'geometry'   => {'type'        => 'MultiPolygon',
                                                           'coordinates' => [[[[33, 28, 0], [37, 28, 0], [37, 26, 0], [33, 26, 0], [33, 28, 0]]]]},
                                          'properties' => {'geographic_area' => {'id' => objects[1].id,
                                                                                 'tag' => 'Q'}},
                                          'id'         => (feature_index.to_i + 1)},
                                         {'type'       => 'Feature',
                                          'geometry'   => {'type'        => 'Point',
                                                           'coordinates' => [33.5, 24.5, 0.0]},
                                          'properties' => {'georeference' => {'id' => objects[2].id}},
                                          'id'         => (feature_index.to_i + 2)},
                                         {'type'       => 'Feature',
                                          'geometry'   => {'type'        => 'MultiPolygon',
                                                           'coordinates' => [[[[36, 25, 0], [37, 25, 0], [37, 24, 0], [36, 24, 0], [36, 25, 0]]]]},
                                          'properties' => {'geographic_item' => {'id' => objects[3].id}},
                                          'id'         => (feature_index.to_i + 3)}]})
    end
  end
end
