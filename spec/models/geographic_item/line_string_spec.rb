require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe GeographicItem::LineString, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'
  context 'that this item' do
    let(:a) { FactoryBot.create(:geographic_item_line_string, line_string: shape_a1.as_binary) }
    specify 'represents a line_string' do
      expect(a.type).to eq('GeographicItem::LineString')
      expect(a.valid?).to be_truthy
      expect(a.geo_object.to_s).to eq('LINESTRING (-32.0 21.0 0.0, -25.0 21.0 0.0, -25.0 16.0 0.0, -21.0 20.0 0.0)')
    end
  end
end
