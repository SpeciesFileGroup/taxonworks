require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe GeographicItem::MultiLineString, type: :model, group: [:geo, :shared_geo] do
  include_context 'stuff for complex geo tests'
  context 'that this item' do
    let(:c) { FactoryBot.build(:geographic_item_multi_line_string, multi_line_string: shape_c.as_binary) }
    specify 'represents a multi_line_string' do
      expect(c.type).to eq('GeographicItem::MultiLineString')
      expect(c.valid?).to be_truthy
      expect(c.geo_object.to_s).to eq('MULTILINESTRING ((23.0 21.0 0.0, 16.0 21.0 0.0, 16.0 16.0 0.0, ' \
                                        '11.0 20.0 0.0), (4.0 12.6 0.0, 16.0 12.6 0.0, 16.0 7.6 0.0), ' \
                                        '(21.0 12.6 0.0, 26.0 12.6 0.0, 22.0 17.6 0.0))')
    end
  end
end
