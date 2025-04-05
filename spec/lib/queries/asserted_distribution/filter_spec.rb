require 'rails_helper'
# require 'support/shared_contexts/shared_geo'

describe Queries::AssertedDistribution::Filter, type: :model, group: [:geo, :collection_objects, :otus, :shared_geo] do
  let(:query) { Queries::AssertedDistribution::Filter }

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_otu) }

  let(:ad1) { FactoryBot.create(:valid_asserted_distribution, otu: o1) }
  let(:ad2) { FactoryBot.create(:valid_asserted_distribution, otu: o2) }
  let(:ad_gz) { FactoryBot.create(:valid_gz_asserted_distribution, otu: o1) }

  let(:small_polygon) { RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 ) }
  let(:big_polygon) { RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 10.0, 10.0 ) }

  let(:small_geo_area) do
    a = FactoryBot.create(:level1_geographic_area)
    a.geographic_items << GeographicItem.create!( geography: small_polygon)
    a
  end

  let(:big_geo_area) do
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

  let(:large_gz) {
    FactoryBot.create(:gazetteer,
    geographic_item:
      FactoryBot.create(:geographic_item, geography: big_polygon),
    name: 'large')
  }

  specify '#taxon_name_id' do
    ad1
    ad2 # Not this one
    o1.update!(taxon_name_id: FactoryBot.create(:root_taxon_name).id)
    q = query.new({taxon_name_id: o1.taxon_name_id})
    expect(q.all.map(&:id)).to contain_exactly(ad1.id)
  end

  specify '#geo_json' do
    ad2 # not this
    b = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    q = query.new({geo_json: big_geo_area.geographic_items.first.to_geo_json})
    expect(q.all).to contain_exactly(b)
  end

  specify '#geo_shape_id #geo_mode (descendants)' do
    ad2 # not this

    b = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    h = {
      geo_shape_id: big_geo_area.parent.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: false
    }
    q = query.new(h)
    expect(q.all).to contain_exactly(b)
  end

  specify '#geo_shape_id #geo_mode (exact)' do
    ad1 # not this
    b = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    h = {
      geo_shape_id: big_geo_area.id,
      geo_shape_type: 'GeographicArea'
    }
    q = query.new(h)

    expect(q.all).to contain_exactly(b)
  end

  specify '#geo_shape_id #geo_mode (spatial) 2' do
    ad1 # not this

    a = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    b = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    h = {
      geo_shape_id: big_geo_area.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: true
    }
    q = query.new(h)

    expect(q.all).to contain_exactly(a, b)
  end

  specify '#geo_shape_id #geo_mode (spatial) 1' do
    a = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    b = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    h = {
      geo_shape_id: small_geo_area.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: true
    }
    q = query.new(h)

    expect(q.all).to contain_exactly(a)
  end

  specify '#wkt 1' do
    a = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    b = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    q = query.new({wkt: big_polygon.to_s})

    expect(q.all).to contain_exactly(a, b)
  end

  specify '#wkt 2' do
    a = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    b = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    q = query.new({wkt: small_polygon.to_s})

    expect(q.all).to contain_exactly(a)
  end

  specify '#otu_id' do
    o = ad1.otu_id
    q = query.new({otu_id: o})
    expect(q.all.map(&:id)).to contain_exactly(ad1.id)
  end

  specify '#geo_shape_id' do
    o = ad1
    h = {
      geo_shape_id: o.asserted_distribution_shape_id,
      geo_shape_type: 'GeographicArea'
    }
    q = query.new(h)
    expect(q.all.map(&:id)).to contain_exactly(ad1.id)
  end

  specify '#presence' do
    ad2
    ad1.update!(is_absent: true)
    q = query.new({presence: true})
    expect(q.all.map(&:id)).to contain_exactly(ad2.id)
  end

  specify '#gazetteer_id small gz' do
    a = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    _b = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    q = query.new({
      geo_shape_id: small_gz.id,
      geo_shape_type: 'Gazetteer',
      geo_mode: true})
    expect(q.all).to contain_exactly(a)
  end

  specify '#gazetteer_id large gz' do
    a = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    b = AssertedDistribution.create!(otu: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    q = query.new({
      geo_shape_id: large_gz.id,
      geo_shape_type: 'Gazetteer',
      geo_mode: true})
    expect(q.all).to contain_exactly(a, b)
  end

  specify '#asserted_distribution_shape_type GA' do
    ad1
    ad_gz
    q = query.new({asserted_distribution_shape_type: 'GeographicArea'})
    expect(q.all).to contain_exactly(ad1)
  end

  specify '#asserted_distribution_shape_type GZ' do
    ad1
    ad_gz
    q = query.new({asserted_distribution_shape_type: 'Gazetteer'})
    expect(q.all).to contain_exactly(ad_gz)
  end

  # # Source query integration
  # specify '#source_id' do
  #   FactoryBot.create(:valid_asserted_distribution)
  #   o = a.source.id
  #   q.source_id = o

  #   expect(q.all.map(&:id)).to contain_exactly(a.id)
  # end

end
