require 'rails_helper'
# require 'support/shared_contexts/shared_geo'

describe Queries::AssertedDistribution::Filter, type: :model, group: [:geo, :collection_objects, :otus, :shared_geo] do
  let(:query) { Queries::AssertedDistribution::Filter }

  let(:o1) { FactoryBot.create(:valid_otu) }
  let(:o2) { FactoryBot.create(:valid_otu) }

  let(:ad1) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o1) }
  let(:ad2) { FactoryBot.create(:valid_asserted_distribution, asserted_distribution_object: o2) }
  let(:ad_gz) { FactoryBot.create(:valid_gazetteer_asserted_distribution, asserted_distribution_object: o1) }

  let(:small_polygon) { RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10), 0, 0, 5.0, 5.0 ) }
  let(:big_polygon) { RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10), 0, 0, 10.0, 10.0 ) }

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
    b = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    q = query.new({geo_json: big_geo_area.geographic_items.first.to_geo_json})
    expect(q.all).to contain_exactly(b)
  end

  specify '#geo_shape_id #geo_mode (descendants)' do
    ad2 # not this

    b = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

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
    b = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    h = {
      geo_shape_id: big_geo_area.id,
      geo_shape_type: 'GeographicArea'
    }
    q = query.new(h)

    expect(q.all).to contain_exactly(b)
  end

  specify '#geo_shape_id #geo_mode (exact) GA and GZ' do
    [ad1, ad_gz] # not this
    b = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    c = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: small_gz, source: FactoryBot.create(:valid_source))

    d = AssertedDistribution.create!(asserted_distribution_object: o2, asserted_distribution_shape: small_gz, source: FactoryBot.create(:valid_source))

    h = {
      geo_shape_id: [big_geo_area.id, small_gz.id],
      geo_shape_type: ['GeographicArea', 'Gazetteer']
    }
    q = query.new(h)

    expect(q.all).to contain_exactly(b, c, d)
  end

  specify '#geo_shape_id #geo_mode (spatial) 2' do
    ad1 # not this

    a = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    b = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    h = {
      geo_shape_id: big_geo_area.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: true
    }
    q = query.new(h)

    expect(q.all).to contain_exactly(a, b)
  end

  specify '#geo_shape_id #geo_mode (spatial) 1' do
    a = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    b = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    h = {
      geo_shape_id: small_geo_area.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: true
    }
    q = query.new(h)

    expect(q.all).to contain_exactly(a)
  end

  specify '#wkt 1' do
    a = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    b = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    q = query.new({wkt: big_polygon.to_s})

    expect(q.all).to contain_exactly(a, b)
  end

  specify '#wkt 2' do
    a = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    b = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    q = query.new({wkt: small_polygon.to_s})

    expect(q.all).to contain_exactly(a)
  end

  specify '#asserted_distribution_object an otu' do
    o = ad1.asserted_distribution_object_id
    q = query.new({
      asserted_distribution_object_id: o,
      asserted_distribution_object_type: 'Otu'
    })
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

  specify '#geo_shape_id small gz spatial' do
    a = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    _b = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))
    c = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: small_gz, source: FactoryBot.create(:valid_source))

    q = query.new({
      geo_shape_id: small_gz.id,
      geo_shape_type: 'Gazetteer',
      geo_mode: true})
    expect(q.all).to contain_exactly(a, c)
  end

  specify '#geo_shape_id large gz spatial' do
    a = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: small_geo_area, source: FactoryBot.create(:valid_source))
    b = AssertedDistribution.create!(asserted_distribution_object: o1, asserted_distribution_shape: big_geo_area, source: FactoryBot.create(:valid_source))

    q = query.new({
      geo_shape_id: large_gz.id,
      geo_shape_type: 'Gazetteer',
      geo_mode: true})
    expect(q.all).to contain_exactly(a, b)
  end

  specify '#geo_shape_id spatial combines GA and GZ geo_shape_ids before testing against ADs' do
    [ad1, ad2, ad_gz]

    big_polygon_neighbor = RspecGeoHelpers.make_polygon(
      RSPEC_GEO_FACTORY.point(15, 10), 0, 0, 10.0, 10.0
    )

    big_geo_area_neighbor = FactoryBot.create(:valid_gazetteer,
      geographic_item: GeographicItem.create!( geography: big_polygon_neighbor)
    )

    # Interior to union of big_polygon and big_polygon_neighbor, but not to either
    # on its own:
    i = RspecGeoHelpers.make_polygon(
      RSPEC_GEO_FACTORY.point(12, 7), 0, 0, 10.0, 5.0
    )

    a = AssertedDistribution.create!(asserted_distribution_object: o1,
      asserted_distribution_shape: FactoryBot.create(:valid_gazetteer,
        geographic_item: GeographicItem.create!( geography: i)),
        source: FactoryBot.create(:valid_source)
    )

    q = query.new({
      geo_shape_id: [big_geo_area.id, big_geo_area_neighbor.id],
      geo_shape_type: ['GeographicArea', 'Gazetteer'],
      geo_mode: true})

    expect(q.all).to contain_exactly(a)
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

  specify '#asserted_distribution_object_type' do
    ad1
    ad_ba = FactoryBot.create(:valid_biological_association_asserted_distribution)
    q = query.new({asserted_distribution_object_type: 'BiologicalAssociation'})
    expect(q.all).to contain_exactly(ad_ba)
  end

  specify '#source_id' do
    source = FactoryBot.create(:valid_source)
    other_source = FactoryBot.create(:valid_source)

    a = FactoryBot.create(:valid_asserted_distribution, source:)
    b = FactoryBot.create(:valid_asserted_distribution, source: other_source)

    q = query.new({source_id: source.id})

    expect(q.all).to contain_exactly(a)
  end

  context 'data attributes' do
    let(:p1) { FactoryBot.create(:valid_predicate) }
    let(:p2) { FactoryBot.create(:valid_predicate) }

    specify '#data_attribute_exact_pair 1' do
      d = InternalAttribute.create!(
        predicate: p1,
        value: '212',
        attribute_subject: ad1
      )
      ad2 # not this

      q = query.new(data_attribute_exact_pair: {p1.id => '212'})
      expect(q.all).to contain_exactly(ad1)
    end

    specify '#data_attribute_exact_pair 2, multiple predicate values are ored' do
      d1 = InternalAttribute.create!(
        predicate: p1,
        value: '212',
        attribute_subject: ad1
      )
      d2 = InternalAttribute.create!(
        predicate: p1,
        value: '313',
        attribute_subject: ad2
      )

      # Must use array form
      q = query.new(
        data_attribute_exact_pair: ["#{p1.id}:212", "#{p1.id}:313"]
      )

      expect(q.all).to contain_exactly(ad1, ad2)
    end

    specify '#data_attribute_wildcard_pair 1' do
      d = InternalAttribute.create!(
        predicate: p1,
        value: '212',
        attribute_subject: ad1
      )
      ad2 # not this

      q = query.new(data_attribute_wildcard_pair: {p1.id => '2'})
      expect(q.all).to contain_exactly(ad1)
    end

    specify '#data_attribute_wildcard_pair 2, multiple predicate values are ored' do
      d1 = InternalAttribute.create!(
        predicate: p1,
        value: '212',
        attribute_subject: ad1
      )
      d2 = InternalAttribute.create!(
        predicate: p1,
        value: '313',
        attribute_subject: ad2
      )

      # Must use array form
      q = query.new(
        data_attribute_wildcard_pair: ["#{p1.id}:21", "#{p1.id}:31"]
      )

      expect(q.all).to contain_exactly(ad1, ad2)
    end

    specify '#data_attribute_wildcard_pair and #data_attribute_exact_pair are anded' do
      d1 = InternalAttribute.create!(
        predicate: p1,
        value: '212',
        attribute_subject: ad1
      )
      d2 = InternalAttribute.create!(
        predicate: p1,
        value: '313',
        attribute_subject: ad2
      )

      # Must use array form
      q = query.new(
        data_attribute_wildcard_pair: ["#{p1.id}:21", "#{p1.id}:31"],
        data_attribute_exact_pair: {p1.id => '313'}
      )

      expect(q.all).to contain_exactly(ad2)
    end

    specify 'multiple predicates with exact pairs' do
      d1 = InternalAttribute.create!(
        predicate: p1,
        value: 'foo',
        attribute_subject: ad1
      )
      d2 = InternalAttribute.create!(
        predicate: p2,
        value: 'bar',
        attribute_subject: ad2
      )

      q = query.new(
        data_attribute_exact_pair: ["#{p1.id}:foo", "#{p2.id}:bar"]
      )

      expect(q.all).to contain_exactly(ad1, ad2)
    end
  end

end
