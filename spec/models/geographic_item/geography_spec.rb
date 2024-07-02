require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe GeographicItem::Geography, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for geography tests'

  let(:geographic_item) { GeographicItem.new }

  context 'can hold any' do
    specify 'point' do
      expect(simple_point.geography.geometry_type.type_name).to eq('Point')
    end

    specify 'line_string' do
      expect(simple_line_string.geography.geometry_type.type_name).to eq('LineString')
    end

    specify 'polygon' do
      expect(simple_polygon.geography.geometry_type.type_name).to eq('Polygon')
    end

    specify 'multi_point' do
      expect(simple_multi_point.geography.geometry_type.type_name).to eq('MultiPoint')
    end

    specify 'multi_line_string' do
      expect(simple_multi_line_string.geography.geometry_type.type_name).to eq('MultiLineString')
    end

    specify 'multi_polygon' do
      expect(simple_multi_polygon.geography.geometry_type.type_name).to eq('MultiPolygon')
    end

    specify 'geometry_collection' do
      expect(simple_geometry_collection.geography.geometry_type.type_name).to eq('GeometryCollection')
    end
  end

  context 'construction via #shape=' do

    let(:geo_json) {
      '{
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [10, 10]
        },
        "properties": {
          "name": "Sample Point",
          "description": "This is a sample point feature."
        }
      }'
    }

    let(:geo_json2) {
      '{
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [20, 20]
        },
        "properties": {
          "name": "Sample Point",
          "description": "This is a sample point feature."
        }
      }'
    }

    specify '#shape=' do
      g = GeographicItem.new(shape: geo_json)
      expect(g.save).to be_truthy
    end

    specify '#shape= 2' do
      g = GeographicItem.create!(shape: geo_json)
      g.update!(shape: geo_json2)
      expect(g.reload.geo_object.to_s).to match(/20/)
    end

    specify '#shape= bad linear ring' do
      bad = '{
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [
            [
              [-80.498221, 25.761437],
              [-80.498221, 25.761959],
              [-80.498221, 25.761959],
              [-80.498221, 25.761437]
            ]
          ]
        },
        "properties": {}
      }'

      g = GeographicItem.new(shape: bad)
      g.valid?
      expect(g.errors[:base]).to be_present
    end

    specify 'for polygon' do
      geographic_item.shape = '{"type":"Feature","geometry":{"type":"Polygon",' \
        '"coordinates":[[[-90.25122106075287,38.619731572825145],[-86.12036168575287,39.77758382625017],' \
        '[-87.62384042143822,41.89478088863241],[-90.25122106075287,38.619731572825145]]]},"properties":{}}'
      expect(geographic_item.valid?).to be_truthy
    end

    specify 'for linestring' do
      geographic_item.shape =
        '{"type":"Feature","geometry":{"type":"LineString","coordinates":[' \
        '[-90.25122106075287,38.619731572825145],' \
        '[-86.12036168575287,39.77758382625017],' \
        '[-87.62384042143822,41.89478088863241]]},"properties":{}}'
      expect(geographic_item.valid?).to be_truthy
    end

    specify 'for "circle"' do
      geographic_item.shape = '{"type":"Feature","geometry":{"type":"Point",' \
        '"coordinates":[-88.09681320155505,40.461195702960666]},' \
        '"properties":{"radius":1468.749413840412, "name":"Paxton City Hall"}}'
      expect(geographic_item.valid?).to be_truthy
    end
  end

  context '#geo_object_type gives underlying shape' do
    specify '#geo_object_type' do
      expect(geographic_item).to respond_to(:geo_object_type)
    end

    specify '#geo_object_type when item not saved' do
      geographic_item.point = simple_shapes[:point]
      expect(geographic_item.geo_object_type).to eq(:point)
    end
  end

  context 'validation' do
    specify 'some data must be provided' do
      geographic_item.valid?
      expect(geographic_item.errors[:base]).to be_present
    end

    specify 'invalid data for point is invalid' do
      geographic_item.point = 'Some string'
      expect(geographic_item.valid?).to be_falsey
    end

    specify 'a valid point is valid' do
      expect(simple_point.valid?).to be_truthy
    end

    specify "a good point didn't change on creation" do
      expect(simple_point.geography.x).to eq 10
    end

    specify 'a point, when provided, has a legal geography' do
      geographic_item.geography = simple_rgeo_point
      expect(geographic_item.valid?).to be_truthy
    end

    specify 'geography can change shape' do
      simple_point.geography = simple_polygon.geography
      expect(simple_point.valid?).to be_truthy
      expect(simple_point.geo_object_type).to eq(:polygon)
    end
  end

  context '#geo_object' do
    before {
      geographic_item.geography = simple_rgeo_point
    }

    specify '#geo_object returns stored data' do
      geographic_item.save!
      expect(geographic_item.geo_object).to eq(simple_rgeo_point)
    end

    specify '#geo_object returns stored db data' do
      geographic_item.save!
      geo_id = geographic_item.id
      expect(GeographicItem.find(geo_id).geo_object).to eq geographic_item.geo_object
    end
  end

  context 'instance methods' do
    specify '#geo_object' do
      expect(geographic_item).to respond_to(:geo_object)
    end

    specify '#contains? - to see if one object is contained by another.' do
      expect(geographic_item).to respond_to(:contains?)
    end

    specify '#within? -  to see if one object is within another.' do
      expect(geographic_item).to respond_to(:within?)
    end

    specify '#contains? if one object is inside the area defined by the other (watch out for holes)' do
      #expect(k.contains?(p1.geo_object)).to be_truthy
    end

    specify '#contains? if one object is inside the area defined by the other (watch out for holes)' do
      #expect(e1.contains?(p10.geo_object)).to be_falsey
    end

    specify '#st_centroid returns a lat/lng of the centroid of the GeoObject' do
      simple_polygon.save!
      expect(simple_polygon.st_centroid).to eq('POINT(5 5)')
    end
  end

  context 'class methods' do

    specify '::within_radius_of_item' do
        expect(GeographicItem).to respond_to(:within_radius_of_item)
      end

    specify '::intersecting method' do
      expect(GeographicItem).to respond_to(:intersecting)
    end
  end
end
