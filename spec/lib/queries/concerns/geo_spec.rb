require 'rails_helper'

describe Queries::Concerns::Geo, type: :model, group: [:geo, :filter] do
  let(:otu) { FactoryBot.create(:valid_otu) }

  let(:small_polygon) { RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 ) }
  let(:medium_polygon) { RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 7.0, 7.0 ) }
  let(:big_polygon) { RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 10.0, 10.0 ) }

  let(:small_ga) do
    a = FactoryBot.create(:level1_geographic_area)
    a.geographic_items << GeographicItem.create!( geography: small_polygon)
    a
  end

  let(:medium_ga) do
    a = FactoryBot.create(:level1_geographic_area)
    a.geographic_items << GeographicItem.create!( geography: medium_polygon)
    a
  end

  let(:large_ga) do
    b = FactoryBot.create(:level1_geographic_area)
    b.geographic_items << GeographicItem.create!( geography: big_polygon)
    b
  end

  let(:small_gz) {
    FactoryBot.create(:gazetteer,
    geographic_item:
      FactoryBot.create(:geographic_item, geography: small_polygon),
    name: 'small')
  }

  let(:medium_gz) {
    FactoryBot.create(:gazetteer,
    geographic_item:
      FactoryBot.create(:geographic_item, geography: medium_polygon),
    name: 'medium')
  }

  let(:large_gz) {
    FactoryBot.create(:gazetteer,
    geographic_item:
      FactoryBot.create(:geographic_item, geography: big_polygon),
    name: 'large')
  }

  let(:ad_medium_ga) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object:,
    asserted_distribution_shape: medium_ga) }
  let(:ad_large_ga) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object:,
    asserted_distribution_shape: large_ga) }
  let(:ad_medium_gz) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object:,
    asserted_distribution_shape: medium_gz) }

  let!(:q) { ::Queries::AssertedDistribution::Filter }

  specify '#param_shapes_by_type' do
    [medium_ga, small_gz, large_gz] # not these

    f = q.new({
      geo_shape_id: [small_ga.id, medium_gz.id, large_ga.id],
      geo_shape_type: ['GeographicArea', 'Gazetteer', 'GeographicArea']
    })

    ga_ids, gz_ids = f.param_shapes_by_type

    expect(ga_ids).to contain_exactly(small_ga.id, large_ga.id)
    expect(gz_ids).to contain_exactly(medium_gz.id)
  end

  specify '#shapes_for_geo_mode Exact' do
    [medium_ga, small_ga, large_gz] # not these

    f = q.new({
      geo_shape_id: [small_gz.id, medium_gz.id, large_ga.id],
      geo_shape_type: ['Gazetteer', 'Gazetteer', 'GeographicArea']
    })

    gas, gzs = f.shapes_for_geo_mode

    expect(gas.to_a).to contain_exactly(large_ga)
    expect(gzs.to_a).to contain_exactly(small_gz, medium_gz)
  end

  specify '#shapes_for_geo_mode Spatial' do
    [medium_ga, small_ga, large_ga, large_gz] # not these

    f = q.new({
      geo_shape_id: [medium_gz.id, large_gz.id, medium_ga.id],
      geo_shape_type: ['Gazetteer', 'Gazetteer', 'GeographicArea'],
      geo_mode: true # spatial
    })

    gas, gzs = f.shapes_for_geo_mode

    expect(gas.to_a).to contain_exactly(medium_ga)
    expect(gzs.to_a).to contain_exactly(medium_gz, large_gz)
  end

  specify '#shapes_for_geo_mode Descendants' do
    [medium_ga, small_ga, large_ga, large_gz] # not these
    large_ga.add_child(medium_ga)
    medium_ga.add_child(small_ga)

    f = q.new({
      geo_shape_id: [small_gz.id, medium_ga.id],
      geo_shape_type: ['Gazetteer', 'GeographicArea'],
      geo_mode: false
    })

    gas, gzs = f.shapes_for_geo_mode

    expect(gas.to_a).to contain_exactly(small_ga, medium_ga)
    # Note small_gz is a descendant of itself, even though Gazetteer doesn't
    # formally support a hierarchy.
    expect(gzs.to_a).to eq [small_gz]
  end
end