require 'rails_helper'

describe GeographicItem::LineString, type:  :model, group: :geo do
  context 'that this item' do
    let(:a) { FactoryGirl.create(:geographic_item_line_string, :line_string => SHAPE_A.as_binary) }
    specify 'represents a line_string' do
      expect(a.type).to eq('GeographicItem::LineString')
      expect(a.valid?).to be_truthy
      expect(a.geo_object.to_s).to eq('LINESTRING (-32.0 21.0 0.0, -25.0 21.0 0.0, -25.0 16.0 0.0, -21.0 20.0 0.0)')
    end

    specify 'that a line_string knows how to emits its own hash' do
      expect(a.rendering_hash).to eq(lines: [[[-32.0, 21.0], [-25.0, 21.0], [-25.0, 16.0], [-21.0, 20.0]]])
    end

    specify 'returns a lat/lng of the first point of the GeoObject' do
      expect(a.start_point).to eq([21.0, -32.0])
    end

    specify '#st_start_point returns the first POINT of the GeoObject' do
      expect(a.st_start_point.to_s).to eq('POINT (-32.0 21.0 0.0)')
    end

  end
end
