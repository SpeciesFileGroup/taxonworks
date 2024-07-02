require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe GeographicItem::Point, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'
  context 'that this item' do
    let(:r2024) { FactoryBot.build(:geographic_item_point, point: room2024.as_binary) }

    specify 'represents a point' do
      expect(r2024.type).to eq('GeographicItem::Point')
      expect(r2024.valid?).to be_truthy
      expect(r2024.geo_object.to_s).to eq('POINT (-88.241413 40.091655 0.0)')
    end
  end
end
