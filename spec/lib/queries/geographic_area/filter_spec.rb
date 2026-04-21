require 'rails_helper'

describe Queries::GeographicArea::Filter, type: :model, group: [:geo] do
  let(:inside_point) { 'POINT (5 5)' }
  let(:outside_point) { 'POINT (15 15)' }
  let(:polygon) { 'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0))' }

  let!(:hit) do
    geographic_area = FactoryBot.create(:valid_geographic_area, name: 'Hit area')
    geographic_area.geographic_items << GeographicItem.create!(geography: polygon)
    geographic_area
  end

  let!(:miss) do
    geographic_area = FactoryBot.create(:valid_geographic_area, name: 'Miss area')
    geographic_area.geographic_items << GeographicItem.create!(geography: 'POLYGON ((20 20, 30 20, 30 30, 20 30, 20 20))')
    geographic_area
  end

  specify '#containing_point hit' do
    query = described_class.new(containing_point: inside_point)

    expect(query.all).to contain_exactly(hit)
  end

  specify '#containing_point miss' do
    query = described_class.new(containing_point: outside_point)

    expect(query.all).to be_empty
  end
end
