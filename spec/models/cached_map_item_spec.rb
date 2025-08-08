require 'rails_helper'

RSpec.describe CachedMapItem, type: :model, group: [:geo, :cached_map] do

  include_context 'cached map scenario'

  specify '#translate_geographic_item_id 1' do
    expect(CachedMapItem.translate_geographic_item_id(gi2.id, true, true, ['ne_states'])).to contain_exactly(gi1.id)
  end

  specify '#translate_geographic_item_id 2' do
    expect(CachedMapItem.translate_geographic_item_id(gi3.id, true, true, ['ne_states'])).to contain_exactly(gi1.id)
  end

  context 'Gazetteer-backed asserted distributions' do
    let(:gz) { FactoryBot.create(:valid_gazetteer, geographic_item_id: gi2.id) }
    let(:ad) { FactoryBot.create(:valid_otu_asserted_distribution,
      asserted_distribution_shape: gz) }

    specify 'Translates CachedMapItem' do
      [gz, ad]
      Delayed::Worker.new.work_off
      expect(CachedMapItem.first.geographic_item_id).to eq(gi1.id)
    end

    specify 'Creates CachedMapItemTranslation for Gazetteer-associated GeographicItems' do
      [gz, ad]
      Delayed::Worker.new.work_off
      cmit = CachedMapItemTranslation.first
      expect(cmit.geographic_item_id).to eq(gi2.id)
      expect(cmit.translated_geographic_item_id).to eq(gi1.id)
    end

    specify 'CachedMapItems can be created from line strings' do

      line = 'LINESTRING (2 2, 8 8)'
      gi = GeographicItem.create!(geography: line)
      gz = FactoryBot.create(:valid_gazetteer, geographic_item_id: gi.id)
      FactoryBot.create(:valid_asserted_distribution,
        asserted_distribution_shape: gz)

      Delayed::Worker.new.work_off
      expect(CachedMapItem.first.geographic_item_id).to eq(gi1.id)
    end
  end

end
