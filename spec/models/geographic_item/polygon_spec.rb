require 'rails_helper'

describe GeographicItem::Polygon, :type => :model do
  context 'that this item' do
    let(:k) { FactoryGirl.build(:geographic_item_polygon, :polygon => SHAPE_K.as_binary) }
    specify 'represents a polygon' do
      expect(k.type).to eq('GeographicItem::Polygon')
      expect(k.valid?).to be_truthy
      expect(k.geo_object.to_s).to eq('POLYGON ((-33.0 -11.0 0.0, -33.0 -23.0 0.0, -21.0 -23.0 0.0, -21.0 -11.0 0.0, -27.0 -13.0 0.0, -33.0 -11.0 0.0))')
    end

    specify 'that a polygon knows how to emits its own hash' do
      expect(k.rendering_hash).to eq(polygons: [[[-33.0, -11.0], [-33.0, -23.0], [-21.0, -23.0],
                                                 [-21.0, -11.0], [-27.0, -13.0], [-33.0, -11.0]]])
    end

    specify 'returns a lat/lng of the first point of the GeoObject' do
      expect(k.start_point).to eq([-11.0, -33.0])
    end

    specify '#st_start_point returns the first POINT of the GeoObject' do
      expect(k.st_start_point.to_s).to eq('POINT (-33.0 -11.0 0.0)')
    end

  end
end
