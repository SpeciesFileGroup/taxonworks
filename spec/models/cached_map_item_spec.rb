require 'rails_helper'

RSpec.describe CachedMapItem, type: :model, group: [:geo, :cached_map] do

  include_context 'cached map scenario'

  specify '#translate_geographic_item_id' do
    expect(CachedMapItem.translate_geographic_item_id(gi2.id, 'AssertedDistribution',  ['ne_countries'])).to contain_exactly(gi1.id)
  end

  specify '#translate_geographic_item_id' do
    expect(CachedMapItem.translate_geographic_item_id(gi3.id, 'AssertedDistribution', ['ne_countries'])).to contain_exactly(gi1.id)
  end

end
