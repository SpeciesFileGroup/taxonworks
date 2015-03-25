require 'rails_helper'

describe GeographicItem::Point, type: :model, group: :geo do
  context 'that this item' do
    let(:r2024) { FactoryGirl.build(:geographic_item_point, :point => ROOM2024.as_binary) }

    specify 'represents a point' do
      expect(r2024.type).to eq('GeographicItem::Point')
      expect(r2024.valid?).to be_truthy
      expect(r2024.geo_object.to_s).to eq('POINT (-88.241413 40.091655 0.0)')
    end

    specify 'knows how to emits its own hash' do
      expect(r2024.rendering_hash).to eq(points: [[-88.241413, 40.091655]])
    end

    specify 'start_point returns a lat/lng of the first point of the GeoObject' do
      expect(r2024.start_point).to eq([40.091655, -88.241413])
    end

    specify '#st_start_point returns the first POINT of the GeoObject' do
      expect(r2024.st_start_point.to_s).to eq('POINT (-88.241413 40.091655 0.0)')
    end
  end
end
