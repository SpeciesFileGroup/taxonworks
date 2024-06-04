require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe GeographicItem::Geography, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'
  context 'can hold any' do
    specify 'point' do
      point = FactoryBot.build(:geographic_item_geography, geography: room2024.as_binary)
      expect(point.geography.geometry_type.type_name).to eq('Point')
    end

    specify 'line_string' do
      line_string = FactoryBot.build(:geographic_item_geography, geography: shape_a1.as_binary)
      expect(line_string.geography.geometry_type.type_name).to eq('LineString')
    end

    specify 'polygon' do
      polygon = FactoryBot.build(:geographic_item_geography, geography: shape_k.as_binary)
      expect(polygon.geography.geometry_type.type_name).to eq('Polygon')
    end

    specify 'multi_point' do
      multi_point = FactoryBot.build(:geographic_item_geography, geography: rooms20nn.as_binary)
      expect(multi_point.geography.geometry_type.type_name).to eq('MultiPoint')
    end

    specify 'multi_line_string' do
      multi_line_string = FactoryBot.build(:geographic_item_geography, geography: shape_c.as_binary)
      expect(multi_line_string.geography.geometry_type.type_name).to eq('MultiLineString')
    end

    specify 'multi_polygon' do
      multi_polygon = FactoryBot.build(:geographic_item_geography, geography: shape_g.as_binary)
      expect(multi_polygon.geography.geometry_type.type_name).to eq('MultiPolygon')
    end

    specify 'geometry_collection' do
      geometry_collection = FactoryBot.build(:geographic_item_geography, geography: all_shapes.as_binary)
      expect(geometry_collection.geography.geometry_type.type_name).to eq('GeometryCollection')
    end
  end
end
