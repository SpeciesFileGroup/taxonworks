require 'rails_helper'

describe GeographicItem::MultiPoint, :type => :model do
  context 'that this item' do
    let(:rooms) { FactoryGirl.build(:geographic_item_multi_point, :multi_point => ROOMS20NN.as_binary) }
    specify 'represents a multi_point' do
      expect(rooms.type).to eq('GeographicItem::MultiPoint')
      expect(rooms.valid?).to be_truthy
      expect(rooms.geo_object.to_s).to eq('MULTIPOINT ((-88.241421 40.091565 0.0), (-88.241417 40.09161 0.0), (-88.241413 40.091655 0.0))')
    end

    specify 'for a multi_point' do
      expect(rooms.rendering_hash).to eq(points: [[-88.241421, 40.091565],
                                                  [-88.241417, 40.09161],
                                                  [-88.241413, 40.091655]])
    end

    specify 'returns a lat/lng of the first point of the GeoObject' do
      expect(rooms.start_point).to eq([40.091565, -88.241421])
    end

    specify '#st_start_point returns the first POINT of the GeoObject' do
      expect(rooms.st_start_point.to_s).to eq('POINT (-88.241421 40.091565 0.0)')
    end

  end
end
