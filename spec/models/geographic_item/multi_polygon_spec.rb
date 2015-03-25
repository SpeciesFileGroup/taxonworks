require 'rails_helper'

describe GeographicItem::MultiPolygon, type: :model, group: :geo do
  context 'that this item' do
    let(:g) { FactoryGirl.build(:geographic_item_multi_polygon, :multi_polygon => SHAPE_G.as_binary) }
    specify 'represents a multi_polygon' do
      expect(g.type).to eq('GeographicItem::MultiPolygon')
      expect(g.valid?).to be_truthy
      expect(g.geo_object.to_s).to eq('MULTIPOLYGON (((28.0 2.3 0.0, 23.0 -1.7 0.0, 26.0 -4.8 0.0, 28.0 2.3 0.0)), ((22.0 -6.8 0.0, 22.0 -9.8 0.0, 16.0 -6.8 0.0, 22.0 -6.8 0.0)), ((16.0 2.3 0.0, 14.0 -2.8 0.0, 18.0 -2.8 0.0, 16.0 2.3 0.0)))')
    end

    specify 'for a multi_polygon' do
      expect(g.rendering_hash).to eq(polygons: [[[28.0, 2.3], [23.0, -1.7], [26.0, -4.8], [28.0, 2.3]],
                                                [[22.0, -6.8], [22.0, -9.8], [16.0, -6.8], [22.0, -6.8]],
                                                [[16.0, 2.3], [14.0, -2.8], [18.0, -2.8], [16.0, 2.3]]])
    end

    specify 'returns a lat/lng of the first point of the GeoObject' do
      expect(g.start_point).to eq([2.3, 28.0])
    end

    specify '#st_start_point returns the first POINT of the GeoObject' do
      expect(g.st_start_point.to_s).to eq("POINT (28.0 2.3 0.0)")
    end

  end
end
