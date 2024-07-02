require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe GeographicItem::Polygon, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'
  context 'that this item' do
    let(:k) { FactoryBot.build(:geographic_item_polygon, polygon: shape_k.as_binary) }
    specify 'represents a polygon' do
      expect(k.type).to eq('GeographicItem::Polygon')
      expect(k.valid?).to be_truthy
      expect(k.geo_object.to_s).to eq('POLYGON ((-33.0 -11.0 0.0, -33.0 -23.0 0.0, -21.0 -23.0 0.0, ' \
                                        '-21.0 -11.0 0.0, -27.0 -13.0 0.0, -33.0 -11.0 0.0))')
    end
  end
end
