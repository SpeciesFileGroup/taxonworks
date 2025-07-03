require 'rails_helper'

describe Queries::BiologicalAssociationsGraph::Filter, type: :model, group: [:filter, :biological_association] do

  let(:o1) { Otu.create!(name: 'o1') }
  let(:o2) { Otu.create!(name: 'o2') }
  let(:o3) { Specimen.create! }

  let!(:r1) { FactoryBot.create(:valid_biological_relationship) }
  let!(:r2) { FactoryBot.create(:valid_biological_relationship) }

  let!(:ba1) { BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o2, biological_relationship: r1) }
  let!(:ba2) { BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: r1) }
  let!(:ba3) { BiologicalAssociation.create!(biological_association_subject: o2, biological_association_object: o3, biological_relationship: r2) }

  let!(:bag) {
    bag = BiologicalAssociationsGraph.create!(name: 'Frodos all the way down')
    bag.biological_associations << ba1
    bag.biological_associations << ba2
    bag.biological_associations << ba3
    bag
  }

  let(:ga) {
    a = FactoryBot.create(:level1_geographic_area)
    a.geographic_items << GeographicItem.create!(
      geography: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )
    )
    a
  }

  let(:root) { FactoryBot.create(:root_taxon_name) }

  let(:query) { Queries::BiologicalAssociationsGraph::Filter }

  specify 'spatial matches on graph' do
    source = FactoryBot.create(:valid_source)
    AssertedDistribution.create!(asserted_distribution_object: bag,asserted_distribution_shape: ga, source:)

    o = {
      geo_shape_id: ga.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: true
    }

    q = query.new(o)

    expect(q.all.map(&:id)).to contain_exactly( bag.id )
  end

  specify 'spatial doesn\'t match on nodes' do
    source = FactoryBot.create(:valid_source)
    AssertedDistribution.create!(asserted_distribution_object: ba1,asserted_distribution_shape: ga, source:)

    o = {
      geo_shape_id: ga.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: true
    }

    q = query.new(o)

    expect(q.all.map(&:id)).to be_empty
  end

end
