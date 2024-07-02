require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe GeographicItem::MultiPoint, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'
  context 'that this item' do
    let(:rooms) { FactoryBot.build(:geographic_item_multi_point, multi_point: rooms20nn.as_binary) }
    specify 'represents a multi_point' do
      expect(rooms.type).to eq('GeographicItem::MultiPoint')
      expect(rooms.valid?).to be_truthy
      expect(rooms.geo_object.to_s).to eq('MULTIPOINT ((-88.241421 40.091565 0.0), ' \
                                        '(-88.241417 40.09161 0.0), (-88.241413 40.091655 0.0))')
    end
  end
end
