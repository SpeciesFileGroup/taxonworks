require 'rails_helper'

describe Georeference::Gazetteer, type: :model, group: :geo do
  let(:collecting_event) { FactoryBot.create(:valid_collecting_event) }
  let(:gazetteer) { FactoryBot.create(:gazetteer_with_polygon) }

  specify 'sets geographic_item from gazetteer_id' do
    georeference = described_class.new(
      collecting_event:,
      gazetteer_id: gazetteer.id
    )

    expect(georeference).to be_valid
    expect(georeference.geographic_item).to eq(gazetteer.geographic_item)
  end

  specify 'is invalid with an unknown gazetteer_id' do
    georeference = described_class.new(
      collecting_event:,
      gazetteer_id: Gazetteer.maximum(:id).to_i + 1
    )

    expect(georeference).to be_invalid
    expect(georeference.errors[:gazetteer_id]).to be_present
  end

  context 'destroying with shared geographic items' do
    specify 'destroys a shared geographic_item only after the georeference is destroyed second' do
      gi = FactoryBot.create(:geographic_item_with_polygon)
      gazetteer = FactoryBot.create(:valid_gazetteer, geographic_item: gi)
      georeference = FactoryBot.create(
        :georeference_gazetteer,
        gazetteer_record: gazetteer,
        collecting_event:
      )

      gazetteer.destroy!
      expect(GeographicItem.where(id: gi.id).exists?).to be(true)

      georeference.destroy!
      expect(GeographicItem.where(id: gi.id).exists?).to be(false)
    end

    specify 'destroys a shared geographic_item only after the gazetteer is destroyed second' do
      gi = FactoryBot.create(:geographic_item_with_polygon)
      gazetteer = FactoryBot.create(:valid_gazetteer, geographic_item: gi)
      georeference = FactoryBot.create(
        :georeference_gazetteer,
        gazetteer_record: gazetteer,
        collecting_event:
      )

      georeference.destroy!
      expect(GeographicItem.where(id: gi.id).exists?).to be(true)

      gazetteer.destroy!
      expect(GeographicItem.where(id: gi.id).exists?).to be(false)
    end
  end
end
