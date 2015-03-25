require 'rails_helper'

describe GeographicItem::MultiLineString, type: :model, group: :geo do
  context 'that this item' do
    let(:c) { FactoryGirl.build(:geographic_item_multi_line_string, :multi_line_string => SHAPE_C.as_binary) }
    specify 'represents a multi_line_string' do
      expect(c.type).to eq('GeographicItem::MultiLineString')
      expect(c.valid?).to be_truthy
      expect(c.geo_object.to_s).to eq('MULTILINESTRING ((23.0 21.0 0.0, 16.0 21.0 0.0, 16.0 16.0 0.0, 11.0 20.0 0.0), (4.0 12.6 0.0, 16.0 12.6 0.0, 16.0 7.6 0.0), (21.0 12.6 0.0, 26.0 12.6 0.0, 22.0 17.6 0.0))')
    end

    specify 'for a multi_line_string' do
      expect(c.rendering_hash).to eq(lines: [[[23.0, 21.0], [16.0, 21.0], [16.0, 16.0], [11.0, 20.0]],
                                             [[4.0, 12.6], [16.0, 12.6], [16.0, 7.6]],
                                             [[21.0, 12.6], [26.0, 12.6], [22.0, 17.6]]])
    end

    specify 'returns a lat/lng of the first point of the GeoObject' do
      expect(c.start_point).to eq([21.0, 23.0])
    end

    specify '#st_start_point returns the first POINT of the GeoObject' do
      expect(c.st_start_point.to_s).to eq('POINT (23.0 21.0 0.0)')
    end

  end
end
