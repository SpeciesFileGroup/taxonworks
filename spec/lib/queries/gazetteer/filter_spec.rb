require 'rails_helper'

describe Queries::Gazetteer::Filter, type: :model, group: [:geo] do
  let(:inside_point) { 'POINT (5 5)' }
  let(:outside_point) { 'POINT (15 15)' }

  let!(:hit) do
    FactoryBot.create(
      :valid_gazetteer,
      name: 'Hit gazetteer',
      geographic_item: GeographicItem.create!(geography: 'POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0))')
    )
  end

  let!(:miss) do
    FactoryBot.create(
      :valid_gazetteer,
      name: 'Miss gazetteer',
      geographic_item: GeographicItem.create!(geography: 'POLYGON ((20 20, 30 20, 30 30, 20 30, 20 20))')
    )
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
