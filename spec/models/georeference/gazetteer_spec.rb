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
end
