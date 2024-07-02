require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe GeographicItem::MultiPolygon, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'
  context 'that this item' do
    let(:g) { FactoryBot.build(:geographic_item_multi_polygon, multi_polygon: shape_g.as_binary) }
    specify 'represents a multi_polygon' do
      expect(g.type).to eq('GeographicItem::MultiPolygon')
      expect(g.valid?).to be_truthy
      expect(g.geo_object.to_s).to eq('MULTIPOLYGON (((28.0 2.3 0.0, 23.0 -1.7 0.0, ' \
                                        '26.0 -4.8 0.0, 28.0 2.3 0.0)), ((22.0 -6.8 0.0, ' \
                                        '22.0 -9.8 0.0, 16.0 -6.8 0.0, 22.0 -6.8 0.0)), ' \
                                        '((16.0 2.3 0.0, 14.0 -2.8 0.0, 18.0 -2.8 0.0, 16.0 2.3 0.0)))')
    end
  end
end
