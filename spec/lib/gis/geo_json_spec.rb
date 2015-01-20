require 'rails_helper'

describe Gis::GeoJSON do

  before(:all) do
    clean_slate_geo
    generate_political_areas_with_collecting_events
    generate_geo_test_objects
  end

  after(:all) do
    clean_slate_geo
    User.delete_all
    Project.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!('users')
    ActiveRecord::Base.connection.reset_pk_sequence!('projects')
  end

  context 'outputting GeoJSON "Feature"s ' do
    context 'geographic_item' do
      specify 'that a geographic_item can produce a properly formed feature' do
        # pending
        expect(Gis::GeoJSON.feature_collection([@ce_p1.georeferences.first.geographic_item]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[36.5,27.5,0.0]},"properties":{"geographic_item":{"id":31}},"id":0}]}')
      end

      specify 'that multiple features can be produced by geographic_items' do
        expect(Gis::GeoJSON.feature_collection([@ce_p1.georeferences.first.geographic_item,
                                                @ce_old_boxia_2.georeferences.first.geographic_item]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[36.5,27.5,0.0]},"properties":{"geographic_item":{"id":31}},"id":0},{"type":"Feature","geometry":{"type":"Point","coordinates":[34.5,25.5,0.0]},"properties":{"geographic_item":{"id":42}},"id":1}]}')
      end

      specify 'that the geographic_item type "point" produce GeoJSON' do
        expect(Gis::GeoJSON.feature_collection([@ce_p1.georeferences.first.geographic_item]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[36.5,27.5,0.0]},"properties":{"geographic_item":{"id":31}},"id":0}]}')
      end

      specify 'that the geographic_item type "line_string" produce GeoJSON' do
        expect(Gis::GeoJSON.feature_collection([@a]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"LineString","coordinates":[[-32.0,21.0,0.0],[-25.0,21.0,0.0],[-25.0,16.0,0.0],[-21.0,20.0,0.0]]},"properties":{"geographic_item":{"id":66}},"id":0}]}')
      end

      specify 'that the geographic_item type "polygon" produce GeoJSON' do
        expect(Gis::GeoJSON.feature_collection([@b]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-14.0,23.0,0.0],[-14.0,11.0,0.0],[-2.0,11.0,0.0],[-2.0,23.0,0.0],[-8.0,21.0,0.0],[-14.0,23.0,0.0]],[[-11.0,18.0,0.0],[-8.0,17.0,0.0],[-6.0,20.0,0.0],[-4.0,16.0,0.0],[-7.0,13.0,0.0],[-11.0,14.0,0.0],[-11.0,18.0,0.0]]]},"properties":{"geographic_item":{"id":69}},"id":0}]}')
      end

      specify 'that the geographic_item type "multi_point" produce GeoJSON' do
        expect(Gis::GeoJSON.feature_collection([@h]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"MultiPoint","coordinates":[[3.0,-14.0,0.0],[6.0,-12.9,0.0],[5.0,-16.0,0.0],[4.0,-17.9,0.0],[7.0,-17.9,0.0]]},"properties":{"geographic_item":{"id":88}},"id":0}]}')
      end

      specify 'that the geographic_item type "multi_line_string" produce GeoJSON' do
        expect(Gis::GeoJSON.feature_collection([@c]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"MultiLineString","coordinates":[[[23.0,21.0,0.0],[16.0,21.0,0.0],[16.0,16.0,0.0],[11.0,20.0,0.0]],[[4.0,12.6,0.0],[16.0,12.6,0.0],[16.0,7.6,0.0]],[[21.0,12.6,0.0],[26.0,12.6,0.0],[22.0,17.6,0.0]]]},"properties":{"geographic_item":{"id":73}},"id":0}]}')
      end

      specify 'that the geographic_item type "multi_polygon" produce GeoJSON' do
        expect(Gis::GeoJSON.feature_collection([@g]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"MultiPolygon","coordinates":[[[[28.0,2.3,0.0],[23.0,-1.7,0.0],[26.0,-4.8,0.0],[28.0,2.3,0.0]]],[[[22.0,-6.8,0.0],[22.0,-9.8,0.0],[16.0,-6.8,0.0],[22.0,-6.8,0.0]]],[[[16.0,2.3,0.0],[14.0,-2.8,0.0],[18.0,-2.8,0.0],[16.0,2.3,0.0]]]]},"properties":{"geographic_item":{"id":87}},"id":0}]}')
      end

      specify 'that the geographic_item type "geometry_collection" produce GeoJSON' do
        expect(Gis::GeoJSON.feature_collection([@all_items]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"GeometryCollection","geometries":[{"type":"LineString","coordinates":[[-32.0,21.0,0.0],[-25.0,21.0,0.0],[-25.0,16.0,0.0],[-21.0,20.0,0.0]]},{"type":"Polygon","coordinates":[[[-14.0,23.0,0.0],[-14.0,11.0,0.0],[-2.0,11.0,0.0],[-2.0,23.0,0.0],[-8.0,21.0,0.0],[-14.0,23.0,0.0]],[[-11.0,18.0,0.0],[-8.0,17.0,0.0],[-6.0,20.0,0.0],[-4.0,16.0,0.0],[-7.0,13.0,0.0],[-11.0,14.0,0.0],[-11.0,18.0,0.0]]]},{"type":"MultiLineString","coordinates":[[[23.0,21.0,0.0],[16.0,21.0,0.0],[16.0,16.0,0.0],[11.0,20.0,0.0]],[[4.0,12.6,0.0],[16.0,12.6,0.0],[16.0,7.6,0.0]],[[21.0,12.6,0.0],[26.0,12.6,0.0],[22.0,17.6,0.0]]]},{"type":"LineString","coordinates":[[-33.0,11.0,0.0],[-24.0,4.0,0.0],[-26.0,13.0,0.0],[-31.0,4.0,0.0],[-33.0,11.0,0.0]]},{"type":"GeometryCollection","geometries":[{"type":"Polygon","coordinates":[[[-19.0,9.0,0.0],[-9.0,9.0,0.0],[-9.0,2.0,0.0],[-19.0,2.0,0.0],[-19.0,9.0,0.0]]]},{"type":"Polygon","coordinates":[[[5.0,-1.0,0.0],[-14.0,-1.0,0.0],[-14.0,6.0,0.0],[5.0,6.0,0.0],[5.0,-1.0,0.0]]]},{"type":"Polygon","coordinates":[[[-11.0,-1.0,0.0],[-11.0,-5.0,0.0],[-7.0,-5.0,0.0],[-7.0,-1.0,0.0],[-11.0,-1.0,0.0]]]},{"type":"Polygon","coordinates":[[[-3.0,-9.0,0.0],[-3.0,-1.0,0.0],[-7.0,-1.0,0.0],[-7.0,-9.0,0.0],[-3.0,-9.0,0.0]]]},{"type":"Polygon","coordinates":[[[-7.0,-9.0,0.0],[-7.0,-5.0,0.0],[-11.0,-5.0,0.0],[-11.0,-9.0,0.0],[-7.0,-9.0,0.0]]]}]},{"type":"MultiLineString","coordinates":[[[-20.0,-1.0,0.0],[-26.0,-6.0,0.0]],[[-21.0,-4.0,0.0],[-31.0,-4.0,0.0]]]},{"type":"MultiPolygon","coordinates":[[[[28.0,2.3,0.0],[23.0,-1.7,0.0],[26.0,-4.8,0.0],[28.0,2.3,0.0]]],[[[22.0,-6.8,0.0],[22.0,-9.8,0.0],[16.0,-6.8,0.0],[22.0,-6.8,0.0]]],[[[16.0,2.3,0.0],[14.0,-2.8,0.0],[18.0,-2.8,0.0],[16.0,2.3,0.0]]]]},{"type":"MultiPoint","coordinates":[[3.0,-14.0,0.0],[6.0,-12.9,0.0],[5.0,-16.0,0.0],[4.0,-17.9,0.0],[7.0,-17.9,0.0]]},{"type":"LineString","coordinates":[[27.0,-14.0,0.0],[18.0,-21.0,0.0],[20.0,-12.0,0.0],[25.0,-23.0,0.0]]},{"type":"GeometryCollection","geometries":[{"type":"MultiPolygon","coordinates":[[[[28.0,2.3,0.0],[23.0,-1.7,0.0],[26.0,-4.8,0.0],[28.0,2.3,0.0]]],[[[22.0,-6.8,0.0],[22.0,-9.8,0.0],[16.0,-6.8,0.0],[22.0,-6.8,0.0]]],[[[16.0,2.3,0.0],[14.0,-2.8,0.0],[18.0,-2.8,0.0],[16.0,2.3,0.0]]]]},{"type":"MultiPoint","coordinates":[[3.0,-14.0,0.0],[6.0,-12.9,0.0],[5.0,-16.0,0.0],[4.0,-17.9,0.0],[7.0,-17.9,0.0]]},{"type":"LineString","coordinates":[[27.0,-14.0,0.0],[18.0,-21.0,0.0],[20.0,-12.0,0.0],[25.0,-23.0,0.0]]}]},{"type":"Polygon","coordinates":[[[-33.0,-11.0,0.0],[-33.0,-23.0,0.0],[-21.0,-23.0,0.0],[-21.0,-11.0,0.0],[-27.0,-13.0,0.0],[-33.0,-11.0,0.0]]]},{"type":"LineString","coordinates":[[-16.0,-15.5,0.0],[-22.0,-20.5,0.0]]},{"type":"MultiPoint","coordinates":[[-88.241421,40.091565,0.0],[-88.241417,40.09161,0.0],[-88.241413,40.091655,0.0]]},{"type":"Point","coordinates":[0.0,0.0,0.0]},{"type":"Point","coordinates":[-29.0,-16.0,0.0]},{"type":"Point","coordinates":[-25.0,-18.0,0.0]},{"type":"Point","coordinates":[-28.0,-21.0,0.0]},{"type":"Point","coordinates":[-19.0,-18.0,0.0]},{"type":"Point","coordinates":[3.0,-14.0,0.0]},{"type":"Point","coordinates":[6.0,-12.9,0.0]},{"type":"Point","coordinates":[5.0,-16.0,0.0]},{"type":"Point","coordinates":[4.0,-17.9,0.0]},{"type":"Point","coordinates":[7.0,-17.9,0.0]},{"type":"Point","coordinates":[32.2,22.0,0.0]},{"type":"Point","coordinates":[-17.0,7.0,0.0]},{"type":"Point","coordinates":[-9.8,5.0,0.0]},{"type":"Point","coordinates":[-10.7,0.0,0.0]},{"type":"Point","coordinates":[-30.0,21.0,0.0]},{"type":"Point","coordinates":[-25.0,18.3,0.0]},{"type":"Point","coordinates":[-23.0,18.0,0.0]},{"type":"Point","coordinates":[-19.6,-13.0,0.0]},{"type":"Point","coordinates":[-7.6,14.2,0.0]},{"type":"Point","coordinates":[-4.6,11.9,0.0]},{"type":"Point","coordinates":[-8.0,-4.0,0.0]},{"type":"Point","coordinates":[-4.0,-8.0,0.0]},{"type":"Point","coordinates":[-10.0,-6.0,0.0]},{"type":"Polygon","coordinates":[[[-1.0,1.0,0.0],[1.0,1.0,0.0],[1.0,-1.0,0.0],[-1.0,-1.0,0.0],[-1.0,1.0,0.0]]]},{"type":"Polygon","coordinates":[[[-2.0,2.0,0.0],[2.0,2.0,0.0],[2.0,-2.0,0.0],[-2.0,-2.0,0.0],[-2.0,2.0,0.0]]]},{"type":"Polygon","coordinates":[[[-3.0,3.0,0.0],[3.0,3.0,0.0],[3.0,-3.0,0.0],[-3.0,-3.0,0.0],[-3.0,3.0,0.0]]]},{"type":"Polygon","coordinates":[[[-4.0,4.0,0.0],[4.0,4.0,0.0],[4.0,-4.0,0.0],[-4.0,-4.0,0.0],[-4.0,4.0,0.0]]]}]},"properties":{"geographic_item":{"id":97}},"id":0}]}')
      end

    end

    context 'geographic_area' do
      specify 'that a geographic_area can produce a properly formed feature' do
        expect(Gis::GeoJSON.feature_collection([@ce_p1.geographic_area]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"MultiPolygon","coordinates":[[[[36.0,28.0,0.0],[37.0,28.0,0.0],[37.0,27.0,0.0],[36.0,27.0,0.0],[36.0,28.0,0.0]]]]},"properties":{"geographic_area":{"id":57}},"id":0}]}')
      end

    end

    context 'georeference' do
      specify 'that a georeference can produce a properly formed feature' do
        expect(Gis::GeoJSON.feature_collection([@ce_p1.georeferences.first]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[36.5,27.5,0.0]},"properties":{"georeference":{"id":3}},"id":0}]}')
      end

    end

    context 'collecting_event' do
      specify 'that a collecting_event can produce a properly formed feature' do
        expect(Gis::GeoJSON.feature_collection([@ce_p1]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[36.5,27.5,0.0]},"properties":{"collecting_event":{"id":4}},"id":0}]}')
      end

    end
  end

  context 'collecting_event, geographic_area, georeference, geographic_item' do
    specify 'that feature_collection can take an array of types of objects' do
      expect(Gis::GeoJSON.feature_collection([@ce_old_boxia_2, @area_q, @gr_m4, @item_p4]).to_json).to eq('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[34.5,25.5,0.0]},"properties":{"collecting_event":{"id":19}},"id":0},{"type":"Feature","geometry":{"type":"MultiPolygon","coordinates":[[[[33.0,28.0,0.0],[37.0,28.0,0.0],[37.0,26.0,0.0],[33.0,26.0,0.0],[33.0,28.0,0.0]]]]},"properties":{"geographic_area":{"id":10}},"id":1},{"type":"Feature","geometry":{"type":"Point","coordinates":[33.5,24.5,0.0]},"properties":{"georeference":{"id":10}},"id":2},{"type":"Feature","geometry":{"type":"MultiPolygon","coordinates":[[[[36.0,25.0,0.0],[37.0,25.0,0.0],[37.0,24.0,0.0],[36.0,24.0,0.0],[36.0,25.0,0.0]]]]},"properties":{"geographic_item":{"id":16}},"id":3}]}')
    end
  end
end
