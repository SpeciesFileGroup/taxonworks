require 'rails_helper'

describe Queries::Observation::Filter, type: :model, group: [:observation_matrix] do

  let(:q) { Queries::Observation::Filter.new({}) }

  specify '#descriptor_id' do
    o = FactoryBot.create(:valid_observation)
    FactoryBot.create(:valid_observation)

    q.descriptor_id = o.descriptor_id
    expect(q.all.map(&:id)).to contain_exactly(o.id)
  end

  specify '#taxon_name_id' do
    p = FactoryBot.create(:valid_protonym)
    otu = Otu.create!(taxon_name: p)

    o = FactoryBot.create(:valid_observation, observation_object: otu)
    FactoryBot.create(:valid_observation)

    q.taxon_name_id = p.id

    expect(q.all.map(&:id)).to contain_exactly(o.id)
  end

  specify 'spatial only matches otu observations' do
    p = RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )

    a = FactoryBot.create(:level1_geographic_area)
    a.geographic_items << GeographicItem.create!(geography: p)

    o = FactoryBot.create(:valid_observation,
      observation_object: FactoryBot.create(:valid_collection_object))

    AssertedDistribution.create!(asserted_distribution_object: o,asserted_distribution_shape: a, source: FactoryBot.create(:valid_source))

    q.wkt = p.to_s

    expect(q.all.map(&:id)).to be_empty
  end

  specify '#wkt' do
    p = RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )

    a = FactoryBot.create(:level1_geographic_area)
    a.geographic_items << GeographicItem.create!(geography: p)

    o = FactoryBot.create(:valid_observation,
      observation_object: FactoryBot.create(:valid_otu))
    FactoryBot.create(:valid_observation, # not this one
      observation_object: FactoryBot.create(:valid_otu))

    AssertedDistribution.create!(asserted_distribution_object: o,asserted_distribution_shape: a, source: FactoryBot.create(:valid_source))

    q.wkt = p.to_s

    expect(q.all.map(&:id)).to contain_exactly( o.id )
  end

    specify '#geo_shape_id, #geo_shape_type, #geo_mode spatial' do
    p = RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )

    g = FactoryBot.create(:valid_gazetteer)
    g.geographic_item.geography = p

    o = FactoryBot.create(:valid_observation,
      observation_object: FactoryBot.create(:valid_otu))
    FactoryBot.create(:valid_observation, # not this one
      observation_object: FactoryBot.create(:valid_otu))

    AssertedDistribution.create!(asserted_distribution_object: o,asserted_distribution_shape: g, source: FactoryBot.create(:valid_source))

    q.geo_shape_id = g.id
    q.geo_shape_type = 'Gazetteer'

    expect(q.all.map(&:id)).to contain_exactly( o.id )
  end

end
