require 'rails_helper'

describe Queries::BiologicalAssociation::Filter, type: :model, group: [:filter] do

  let(:o1) { Otu.create!(name: 'small') }
  let(:o2) { Otu.create!(name: 'big') }
  let(:o3) { Specimen.create! }

  let!(:r1) { FactoryBot.create(:valid_biological_relationship) }
  let!(:r2) { FactoryBot.create(:valid_biological_relationship) }

  let!(:ba1) { BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o2, biological_relationship: r1) }
  let!(:ba2) { BiologicalAssociation.create!(biological_association_subject: o1, biological_association_object: o3, biological_relationship: r1) }
  let!(:ba3) { BiologicalAssociation.create!(biological_association_subject: o2, biological_association_object: o3, biological_relationship: r2) }

  let(:root) { FactoryBot.create(:root_taxon_name) }

  let(:query) { Queries::BiologicalAssociation::Filter }

  specify 'collecting_event_query' do
    ce = FactoryBot.create(:valid_collecting_event)
    o3.update!(collecting_event: ce)

    h = { 'collecting_event_query':  {'collecting_event_id': ce.id} }
    q = query.new(h)

    expect(q.all).to contain_exactly(ba2, ba3)
  end

  context 'subqueries' do
    specify 'A->B->A params' do
      h = { 'collecting_event_query':  { 'biological_association_query': { 'taxon_name_id': ['99'], 'descendants':  'true'}} }
      q = query.new(h)
      expect(q.collecting_event_query.biological_association_query.taxon_name_id).to contain_exactly('99')
    end

    specify 'A->B->A params 2' do
      h = { 'collecting_event_query':  { 'biological_association_query': { 'taxon_name_id': ['99'], 'descendants':  'true'}} }
      p = ActionController::Parameters.new(h)
      q = query.new(p)
      expect(q.collecting_event_query.biological_association_query.taxon_name_id).to contain_exactly('99')
    end

    specify 'A->B->A permission' do
      h = { 'collecting_event_query':  { 'biological_association_query': { 'taxon_name_id': ['99'], 'descendants':  'true'}} }
      p = ActionController::Parameters.new(h)
      q = query.new(p)
      expect(q.deep_permit(p).to_hash.deep_symbolize_keys).to eq(h)
    end
  end

  specify '#object_scope' do
    g1 =  Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s1 =  Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

    g2 =  Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s2 =  Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: g2)

    o1.update!(taxon_name: s1)
    o2.update!(taxon_name: s2)

    o = { object_taxon_name_id: [s1.id, s2.id] }
    expect(query.new(o).object_scope.map(&:id)).to contain_exactly(ba1.id)
  end

  specify '#subject_scope' do
    g1 =  Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s1 =  Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

    g2 =  Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s2 =  Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: g2)

    o1.update!(taxon_name: s1)
    o2.update!(taxon_name: s2)

    o = { subject_taxon_name_id: [s1.id] }
    expect(query.new(o).subject_scope.map(&:id)).to contain_exactly(ba1.id, ba2.id)
  end

  specify '#subject_taxon_name_id, #object_taxon_name_id, #taxon_name_id_mode 2' do
    g1 =  Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s1 =  Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

    g2 =  Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s2 =  Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: g2)

    o1.update!(taxon_name: s1)
    o2.update!(taxon_name: s2)

    o = { subject_taxon_name_id: s1.id, object_taxon_name_id: g2.id, taxon_name_id_mode: false }
    expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba2.id)
  end

  specify '#subject_taxon_name_id, #object_taxon_name_id, #taxon_name_id_mode, #descendants' do
    g1 =  Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s1 =  Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

    g2 =  Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s2 =  Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: g2)

    o1.update!(taxon_name: s1)
    o2.update!(taxon_name: s2)

    o = { subject_taxon_name_id: s1.id, object_taxon_name_id: g2.id, taxon_name_id_mode: true, descendants: true }
    expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id)
  end

  specify '#taxon_name_id descendants = false' do
    p = FactoryBot.create(:root_taxon_name)
    o1.update!(taxon_name: FactoryBot.create(:valid_taxon_name, parent: p) )

    q = query.new(taxon_name_id: p.id, descendants: false)
    expect(q.all).to contain_exactly()
  end

  specify '#taxon_name_id descendants = true' do
    p = FactoryBot.create(:root_taxon_name)
    o1.update!(taxon_name: FactoryBot.create(:valid_taxon_name, parent: p) )

    q = query.new(taxon_name_id: p.id, descendants: true)
    expect(q.all).to contain_exactly(ba1, ba2)
  end

  specify '#taxon_name_id' do
    o1.update!(taxon_name_id: FactoryBot.create(:root_taxon_name).id)
    q = query.new(taxon_name_id: o1.taxon_name_id)
    expect(q.all).to contain_exactly(ba1, ba2)
  end

  specify '#geo_shape_id #geo_mode = true (spatial) against AssertedDistribution' do
    # smaller
    a = FactoryBot.create(:level1_geographic_area)
    a.geographic_items << GeographicItem.create!(
      geography: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )
    )

    # bigger
    b = FactoryBot.create(:level1_geographic_area)
    b.geographic_items << GeographicItem.create!(
      geography: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 10.0, 10.0 )
    )

    # Use smaller
    AssertedDistribution.create!(asserted_distribution_object: o2, asserted_distribution_shape: a, source: FactoryBot.create(:valid_source))

    # Use bigger
    o = {
      geo_shape_id: b.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: true
    }

    q = query.new(o)

    expect(q.all).to contain_exactly( ba1, ba3 )
  end

  specify '#geo_shape_id #geo_mode = true (spatial) against AssertedDistribution 2' do
    # smaller
    a = FactoryBot.create(:level1_geographic_area)
    s1 = a.geographic_items << GeographicItem.create!(
      geography: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )
    )

    # bigger
    b = FactoryBot.create(:level1_geographic_area)
    s2 = b.geographic_items << GeographicItem.create!(
      geography: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 10.0, 10.0 )
    )

    source = FactoryBot.create(:valid_source)
    # Use smaller
    AssertedDistribution.create!(asserted_distribution_object: o2,asserted_distribution_shape: a, source:)

    # Use smaller
    AssertedDistribution.create!(asserted_distribution_object: ba2,asserted_distribution_shape: a, source:)

    # Use bigger
    o = {
      geo_shape_id: b.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: true
    }

    q = query.new(o)

    expect(q.all).to contain_exactly( ba1, ba2, ba3 )
  end

  context 'with a graph' do
    let(:o_1) { Otu.create!(name: 'o_1') }
    let(:o_2) { Otu.create!(name: 'o_2') }
    let(:o_3) { Specimen.create! }
    let(:ba_1) { BiologicalAssociation.create!(biological_association_subject: o_1, biological_association_object: o_2, biological_relationship: r1) }
    let(:ba_2) { BiologicalAssociation.create!(biological_association_subject: o_2, biological_association_object: o_3, biological_relationship: r2) }
    let(:ba_3) { BiologicalAssociation.create!(biological_association_subject: o_1, biological_association_object: o_3, biological_relationship: r1) }
    let!(:bag) { FactoryBot.create(:valid_biological_associations_graph) }
    let(:ga) {
      a = FactoryBot.create(:level1_geographic_area)
      a.geographic_items << GeographicItem.create!(
        geography: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )
      )
      a
    }

    specify 'spatial all possible asserted_distribution sources' do
      bag.biological_associations << ba_1
      bag.biological_associations << ba_2

      source = FactoryBot.create(:valid_source)
      # On a BiologicalAssociationsGraph
      AssertedDistribution.create!(asserted_distribution_object: bag,asserted_distribution_shape: ga, source:)
      # On a BiologicalAssociation
      AssertedDistribution.create!(asserted_distribution_object: ba_3,asserted_distribution_shape: ga, source:)
      # On the subject/object of a BiologicalAssociation
      AssertedDistribution.create!(asserted_distribution_object: o1,asserted_distribution_shape: ga, source:)

      o = {
        geo_shape_id: ga.id,
        geo_shape_type: 'GeographicArea',
        geo_mode: true
      }

      q = query.new(o)

      expect(q.all.map(&:id)).to contain_exactly( ba_1.id, ba_2.id, ba_3.id, ba1.id, ba2.id )
    end

    specify 'graph asserted_distribution only' do
      bag.biological_associations << ba_1
      bag.biological_associations << ba_2

      source = FactoryBot.create(:valid_source)
      AssertedDistribution.create!(asserted_distribution_object: bag,asserted_distribution_shape: ga, source:)

      o = {
        geo_shape_id: ga.id,
        geo_shape_type: 'GeographicArea',
        geo_mode: true
      }

      q = query.new(o)

      expect(q.all.map(&:id)).to contain_exactly( ba_1.id, ba_2.id )
    end
  end

  specify '#geo_shape_id #geo_mode = true (spatial) against Georeference' do
    a = FactoryBot.create(:level1_geographic_area)
    s = a.geographic_items << GeographicItem.create!(
      geography: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )
    )

    o3.update!(collecting_event: FactoryBot.create(:valid_collecting_event, verbatim_latitude: '7.0', verbatim_longitude: '12.0'))
    g = Georeference::VerbatimData.create!(collecting_event: o3.collecting_event)

    o = {
      geo_shape_id: a.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: true
    }

    q = query.new(o)

    expect(q.all).to contain_exactly( ba2, ba3 )
  end

  specify '#geo_shape_id #geo_mode = true (spatial) #geo_collecting_event_geographic_area' do
    a = FactoryBot.create(:level1_geographic_area)
    s = a.geographic_items << GeographicItem.create!(
      geography: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )
    )

    o3.update!(collecting_event: FactoryBot.create(:valid_collecting_event, geographic_area: a))

    o = {
      geo_shape_id: a.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: true,
      geo_collecting_event_geographic_area: true
    }

    q = query.new(o)

    expect(q.all).to contain_exactly( ba2, ba3 )
  end

  specify '#geo_shape_id #geo_mode = nil (exact) against AssertedDistribution and AssertedDistribution repeated' do
    a = FactoryBot.create(:level1_geographic_area)
    a.geographic_items << GeographicItem.create!(
      geography: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )
    )
    source = FactoryBot.create(:valid_source)
    AssertedDistribution.create!(asserted_distribution_object: o2,asserted_distribution_shape: a, source:)
    AssertedDistribution.create!(asserted_distribution_object: ba3,asserted_distribution_shape: a, source:)

    o = {
      geo_shape_id: a.id,
      geo_shape_type: 'GeographicArea',
      geo_mode: nil # exact
    }
    q = query.new(o)

    # Matches ba3 twice.
    expect(q.all).to contain_exactly( ba1, ba3 )
  end

  specify '#wkt & #taxon_name_id 2' do
    o4 = Specimen.create!
    ba4 = BiologicalAssociation.create!(biological_association_subject: o2, biological_association_object: o4, biological_relationship: r2)

    # o4 gets spatial, o4 does not
    o4.update!(collecting_event: FactoryBot.create(:valid_collecting_event, verbatim_latitude: '7.0', verbatim_longitude: '12.0'))
    g = Georeference::VerbatimData.create!(collecting_event: o4.collecting_event)

    # Both share the same determination
    o3.taxon_determinations << TaxonDetermination.new(
      otu: FactoryBot.create(:valid_otu, taxon_name: FactoryBot.create(:valid_protonym))
    )
    o4.taxon_determinations << TaxonDetermination.new(
      otu: o3.taxon_determinations.first.otu
    )

    o = {
      taxon_name_id: o3.taxon_determinations.first.otu.taxon_name_id,
      wkt: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 ).to_s
    }

    q = query.new(o)
    expect(q.all).to contain_exactly( ba4 ) # not 2 and 3!
  end

  specify '#wkt & #taxon_name_id 1' do
    # Specimen with spatial
    o3.update!(collecting_event: FactoryBot.create(:valid_collecting_event, verbatim_latitude: '7.0', verbatim_longitude: '12.0'))
    g = Georeference::VerbatimData.create!(collecting_event: o3.collecting_event)

    o3.taxon_determinations << TaxonDetermination.new(
      otu: FactoryBot.create(:valid_otu, taxon_name: FactoryBot.create(:valid_protonym))
    )

    o = {
      taxon_name_id: o3.taxon_determinations.first.otu.taxon_name_id,
      wkt: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 ).to_s
    }

    q = query.new(o)
    expect(q.all.map(&:id)).to contain_exactly( ba2.id, ba3.id )
  end

  specify '#wkt spatial against georeference' do
    o3.update!(collecting_event: FactoryBot.create(:valid_collecting_event, verbatim_latitude: '7.0', verbatim_longitude: '12.0'))
    g = Georeference::VerbatimData.create!(collecting_event: o3.collecting_event)
    o = {wkt: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 ).to_s}
    q =  query.new(o)
    expect(q.all.map(&:id)).to contain_exactly( ba2.id, ba3.id )
  end

  specify '#wkt spatial against georeference and AssertedDistribution' do
    p = RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )

    o3.update!(collecting_event: FactoryBot.create(:valid_collecting_event, verbatim_latitude: '7.0', verbatim_longitude: '12.0'))
    g = Georeference::VerbatimData.create!(collecting_event: o3.collecting_event)


    a = FactoryBot.create(:level1_geographic_area)
    a.geographic_items << GeographicItem.create!(geography: p)

    AssertedDistribution.create!(asserted_distribution_object: ba1,asserted_distribution_shape: a, source: FactoryBot.create(:valid_source))

    o = {wkt: p.to_s}
    q =  query.new(o)

    expect(q.all.map(&:id)).to contain_exactly( ba1.id, ba2.id, ba3.id )
  end

  specify '#object_biological_property_id' do
    p = FactoryBot.create(:valid_biological_property)
    s = FactoryBot.create(:valid_biological_relationship_object_type, biological_relationship: r1, biological_property: p)

    o = {object_biological_property_id: p.id}
    expect(query.new(o).all.map(&:id)).to contain_exactly( ba1.id, ba2.id )
  end

  specify '#subject_biological_property_id' do
    p = FactoryBot.create(:valid_biological_property)
    s = FactoryBot.create(:valid_biological_relationship_subject_type, biological_relationship: r1, biological_property: p)

    o = {subject_biological_property_id: p.id}
    expect(query.new(o).all.map(&:id)).to contain_exactly( ba1.id, ba2.id )
  end

  specify '#collecting_event_id on collection_object' do
    a = BiologicalAssociation.create!(
      biological_association_subject: Specimen.create!(collecting_event: FactoryBot.create(:valid_collecting_event)),
      biological_association_object: o3,
      biological_relationship: r2)
    o = {collecting_event_id: a.biological_association_subject.collecting_event.id}
    expect(query.new(o).all.map(&:id)).to contain_exactly( a.id )
  end

  specify '#collecting_event_id on collection_object and field_occurrence' do
    ce = FactoryBot.create(:valid_collecting_event)
    a = BiologicalAssociation.create!(
      biological_association_subject: o3,
      biological_association_object: Specimen.create!(collecting_event: ce),
      biological_relationship: r2)
    b = BiologicalAssociation.create!(
      biological_association_subject: FactoryBot.create(:valid_field_occurrence, collecting_event: ce),
      biological_association_object: o3,
      biological_relationship: r2)
    o = {collecting_event_id: ce.id}
    expect(query.new(o).all.map(&:id)).to contain_exactly( a.id, b.id )
  end

  specify '#otu_id' do
    o = {otu_id: o1.id}
    q = query.new(o)
    expect(q.all.map(&:id)).to contain_exactly( ba1.id, ba2.id )
  end

  specify '#collection_object_id' do
    a = BiologicalAssociation.create!(
      biological_association_subject: Specimen.create!,
      biological_association_object: o3,
      biological_relationship: r2)

    o = {collection_object_id: a.biological_association_subject.id}
    expect(query.new(o).all.map(&:id)).to contain_exactly( a.id )
  end

  specify '#field_occurrence_id' do
    a = BiologicalAssociation.create!(
      biological_association_subject: o3,
      biological_association_object: FactoryBot.create(:valid_field_occurrence),
      biological_relationship: r2)

    o = {field_occurrence_id: a.biological_association_object.id}
    expect(query.new(o).all.map(&:id)).to contain_exactly( a.id )
  end

  specify '#subject_objectglobal_id' do
    o = {subject_object_global_id: o1.to_global_id.to_s}
    expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba2.id )
  end

  specify '#object_object_global_id' do
    o = {object_object_global_id: o2.to_global_id.to_s}
    expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id)
  end

  specify '#subject_object_global_id and #object_object_global_id' do
    o = {subject_object_global_id: o1.to_global_id.to_s, object_object_global_id: o3.to_global_id.to_s}
    expect(query.new(o).all.map(&:id)).to contain_exactly(ba2.id)
  end

  specify '#any_global_id' do
    o = {any_global_id: o2.to_global_id.to_s}
    expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba3.id)
  end

  specify '#biological_relationship_id' do
    o = {biological_relationship_id: r1.id}
    expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba2.id)
  end

  specify '#taxon_name_id 2' do
    g1 =  Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s1 =  Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

    o1.update!(taxon_name: s1)

    o = {taxon_name_id: s1.id}
    expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba2.id)
  end

  specify '#taxon_name_id 1 (descendants true)' do
    g1 =  Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s1 =  Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

    g2 =  Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s2 =  Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: g2)

    o1.update!(taxon_name: s1)

    o = {taxon_name_id: g1.id, descendants: true}
    expect(query.new(o).all.map(&:id)).to contain_exactly(ba1.id, ba2.id)
  end

  specify '#subject_taxon_name_id (Otu)' do
    g1 =  Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s1 =  Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

    g2 =  Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s2 =  Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: g2)

    o2.update!(taxon_name: s1)

    o = {subject_taxon_name_id: g1.id, descendants: true}
    q = query.new(o)
    expect(q.all.map(&:id)).to contain_exactly(ba3.id)
  end

  specify '#object_taxon_name_id (CollectionObject)' do
     g1 = Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s1 = Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

    g2 = Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s2 = Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: g2)

    oz = Otu.create!(taxon_name: s1)
    bz = FactoryBot.create(:valid_biological_association, biological_association_object: oz)

    o = {object_taxon_name_id: g1.id, descendants: true}
    q = query.new(o)
    expect(q.all.map(&:id)).to contain_exactly(bz.id)
   end

  specify '#subject_taxon_name_id (CollectionObject)' do
     g1 =  Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s1 =  Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

    g2 =  Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s2 =  Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: g2)

    oz = Otu.create!(taxon_name: s1)
    bz = FactoryBot.create(:valid_biological_association, biological_association_subject: oz)

    o = {subject_taxon_name_id: g1.id, descendants: true}
    q = query.new(o)
    expect(q.all.map(&:id)).to contain_exactly(bz.id)
   end

  specify '#object_taxon_name_id' do
    g1 =  Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s1 =  Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: g1)

    g2 =  Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
    s2 =  Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: g2)

    o2.update!(taxon_name: s1)
    o = {object_taxon_name_id: g1.id, descendants: true}

    q = query.new(o)

    expect(q.all.map(&:id)).to contain_exactly(ba1.id)
  end

  specify '#biological_associations_graph_id' do
    g = FactoryBot.create(:valid_biological_associations_graph)
    g.biological_associations << ba1
    expect(query.new(biological_associations_graph_id: [g.id]).all.map(&:id)).to contain_exactly(ba1.id)
  end

  context 'sort param' do
    specify 'sort=id orders ascending by id' do
      q = query.new(sort: 'id')
      expect(q.all.map(&:id)).to eq([ba1.id, ba2.id, ba3.id])
    end

    specify 'sort=-id orders descending by id' do
      q = query.new(sort: '-id')
      expect(q.all.map(&:id)).to eq([ba3.id, ba2.id, ba1.id])
    end

    specify 'sort=-updated_at orders by updated_at desc' do
      # touch ba1 last so it becomes the most recently updated
      ba3.touch
      ba2.touch
      ba1.touch
      q = query.new(sort: '-updated_at')
      expect(q.all.map(&:id)).to eq([ba1.id, ba2.id, ba3.id])
    end

    specify 'unknown sort keys are ignored' do
      q = query.new(sort: 'no_such_column,-id')
      expect(q.all.map(&:id)).to eq([ba3.id, ba2.id, ba1.id])
    end

    specify 'sort works alongside filter facets' do
      q = query.new(biological_relationship_id: [r1.id], sort: '-id')
      expect(q.all.map(&:id)).to eq([ba2.id, ba1.id])
    end

    specify 'sort param survives via ActionController::Parameters' do
      p = ActionController::Parameters.new(sort: '-id')
      q = query.new(p)
      expect(q.all.map(&:id)).to eq([ba3.id, ba2.id, ba1.id])
    end

    context 'derived columns' do
      let(:r_alpha) { FactoryBot.create(:valid_biological_relationship, name: 'alpha rel') }
      let(:r_zeta)  { FactoryBot.create(:valid_biological_relationship, name: 'zeta rel') }

      specify 'sort=biological_relationship orders by relationship name' do
        ba_z = BiologicalAssociation.create!(
          biological_association_subject: o1,
          biological_association_object: o2,
          biological_relationship: r_zeta
        )
        ba_a = BiologicalAssociation.create!(
          biological_association_subject: o1,
          biological_association_object: o2,
          biological_relationship: r_alpha
        )

        q = query.new(
          biological_association_id: [ba_a.id, ba_z.id],
          sort: 'biological_relationship'
        )
        expect(q.all.map(&:id)).to eq([ba_a.id, ba_z.id])

        q = query.new(
          biological_association_id: [ba_a.id, ba_z.id],
          sort: '-biological_relationship'
        )
        expect(q.all.map(&:id)).to eq([ba_z.id, ba_a.id])
      end

      context 'taxonomy sorts' do
        let!(:fam_xulidae) {
          Protonym.create!(name: 'Xulidae', rank_class: Ranks.lookup(:iczn, :family), parent: root)
        }
        let!(:fam_aulidae) {
          Protonym.create!(name: 'Aulidae', rank_class: Ranks.lookup(:iczn, :family), parent: root)
        }
        let!(:gen_zus) {
          Protonym.create!(name: 'Zus', rank_class: Ranks.lookup(:iczn, :genus), parent: fam_xulidae)
        }
        let!(:gen_aus) {
          Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: fam_aulidae)
        }

        let!(:otu_zus) { Otu.create!(name: 'zus_otu', taxon_name: gen_zus) }
        let!(:otu_aus) { Otu.create!(name: 'aus_otu', taxon_name: gen_aus) }

        let!(:ba_zus_obj) {
          BiologicalAssociation.create!(
            biological_association_subject: o1,
            biological_association_object: otu_zus,
            biological_relationship: r1
          )
        }
        let!(:ba_aus_obj) {
          BiologicalAssociation.create!(
            biological_association_subject: o1,
            biological_association_object: otu_aus,
            biological_relationship: r1
          )
        }

        specify 'sort=object_taxonomy_genus orders BAs by object OTU genus name' do
          q = query.new(
            biological_association_id: [ba_zus_obj.id, ba_aus_obj.id],
            sort: 'object_taxonomy_genus'
          )
          expect(q.all.map(&:id)).to eq([ba_aus_obj.id, ba_zus_obj.id])
        end

        specify 'sort=-object_taxonomy_family orders BAs by object family desc' do
          q = query.new(
            biological_association_id: [ba_zus_obj.id, ba_aus_obj.id],
            sort: '-object_taxonomy_family'
          )
          expect(q.all.map(&:id)).to eq([ba_zus_obj.id, ba_aus_obj.id])
        end

        specify 'multi-key sort: family asc, then genus desc' do
          # same family for both, differentiate via genus
          gen_bus = Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :genus), parent: fam_aulidae)
          otu_bus = Otu.create!(name: 'bus_otu', taxon_name: gen_bus)
          ba_bus = BiologicalAssociation.create!(
            biological_association_subject: o1,
            biological_association_object: otu_bus,
            biological_relationship: r1
          )

          q = query.new(
            biological_association_id: [ba_zus_obj.id, ba_aus_obj.id, ba_bus.id],
            sort: 'object_taxonomy_family,-object_taxonomy_genus'
          )
          # Aulidae before Xulidae; within Aulidae: Bus desc-before-Aus
          expect(q.all.map(&:id)).to eq([ba_bus.id, ba_aus_obj.id, ba_zus_obj.id])
        end

        specify 'BAs whose object is not an OTU sort to the end' do
          # ba3 has Specimen (o3) as object
          q = query.new(
            biological_association_id: [ba3.id, ba_aus_obj.id],
            sort: 'object_taxonomy_genus'
          )
          # OTU-backed row first, polymorphic-non-OTU row last (NULLS LAST)
          expect(q.all.map(&:id)).to eq([ba_aus_obj.id, ba3.id])
        end
      end

      context 'object_tag sorts (polymorphic)' do
        let!(:gen_zus) {
          Protonym.create!(name: 'Zus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
        }
        let!(:gen_aus) {
          Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: root)
        }
        let!(:otu_zus) { Otu.create!(name: nil, taxon_name: gen_zus) }
        let!(:otu_aus) { Otu.create!(name: nil, taxon_name: gen_aus) }

        let!(:ba_obj_zus) {
          BiologicalAssociation.create!(
            biological_association_subject: o1,
            biological_association_object: otu_zus,
            biological_relationship: r1
          )
        }
        let!(:ba_obj_aus) {
          BiologicalAssociation.create!(
            biological_association_subject: o1,
            biological_association_object: otu_aus,
            biological_relationship: r1
          )
        }

        specify 'sort=object_object_tag orders OTU objects by taxon_name.cached' do
          q = query.new(
            biological_association_id: [ba_obj_zus.id, ba_obj_aus.id],
            sort: 'object_object_tag'
          )
          expect(q.all.map(&:id)).to eq([ba_obj_aus.id, ba_obj_zus.id])
        end

        specify 'sort=-object_object_tag desc' do
          q = query.new(
            biological_association_id: [ba_obj_zus.id, ba_obj_aus.id],
            sort: '-object_object_tag'
          )
          expect(q.all.map(&:id)).to eq([ba_obj_zus.id, ba_obj_aus.id])
        end

        specify 'falls back to otus.name when taxon_name is absent' do
          otu_no_tn = Otu.create!(name: 'Mus', taxon_name: nil)
          ba_no_tn = BiologicalAssociation.create!(
            biological_association_subject: o1,
            biological_association_object: otu_no_tn,
            biological_relationship: r1
          )
          # 'Aus' (cached) < 'Mus' (name) < 'Zus' (cached)
          q = query.new(
            biological_association_id: [ba_obj_zus.id, ba_obj_aus.id, ba_no_tn.id],
            sort: 'object_object_tag'
          )
          expect(q.all.map(&:id)).to eq([ba_obj_aus.id, ba_no_tn.id, ba_obj_zus.id])
        end

        specify 'sort=subject_object_tag works symmetrically' do
          ba_subj_zus = BiologicalAssociation.create!(
            biological_association_subject: otu_zus,
            biological_association_object: o1,
            biological_relationship: r1
          )
          ba_subj_aus = BiologicalAssociation.create!(
            biological_association_subject: otu_aus,
            biological_association_object: o1,
            biological_relationship: r1
          )
          q = query.new(
            biological_association_id: [ba_subj_zus.id, ba_subj_aus.id],
            sort: 'subject_object_tag'
          )
          expect(q.all.map(&:id)).to eq([ba_subj_aus.id, ba_subj_zus.id])
        end

        specify 'CollectionObject objects sort by buffered_collecting_event' do
          co_a = Specimen.create!(buffered_collecting_event: 'Adirondacks')
          co_z = Specimen.create!(buffered_collecting_event: 'Zion')
          ba_co_a = BiologicalAssociation.create!(
            biological_association_subject: o1,
            biological_association_object: co_a,
            biological_relationship: r1
          )
          ba_co_z = BiologicalAssociation.create!(
            biological_association_subject: o1,
            biological_association_object: co_z,
            biological_relationship: r1
          )
          q = query.new(
            biological_association_id: [ba_co_z.id, ba_co_a.id],
            sort: 'object_object_tag'
          )
          expect(q.all.map(&:id)).to eq([ba_co_a.id, ba_co_z.id])
        end
      end

      context 'biological_property sorts' do
        let(:prop_alpha) { FactoryBot.create(:valid_biological_property, name: 'Alpha property') }
        let(:prop_zeta)  { FactoryBot.create(:valid_biological_property, name: 'Zeta property') }
        let(:br_a) { FactoryBot.create(:valid_biological_relationship, name: 'br_a') }
        let(:br_z) { FactoryBot.create(:valid_biological_relationship, name: 'br_z') }

        before do
          # br_a -> subject:Alpha, object:Zeta
          # br_z -> subject:Zeta, object:Alpha
          FactoryBot.create(:valid_biological_relationship_subject_type,
            biological_relationship: br_a, biological_property: prop_alpha)
          FactoryBot.create(:valid_biological_relationship_object_type,
            biological_relationship: br_a, biological_property: prop_zeta)
          FactoryBot.create(:valid_biological_relationship_subject_type,
            biological_relationship: br_z, biological_property: prop_zeta)
          FactoryBot.create(:valid_biological_relationship_object_type,
            biological_relationship: br_z, biological_property: prop_alpha)
        end

        let!(:ba_a_subj) {
          BiologicalAssociation.create!(
            biological_association_subject: o1,
            biological_association_object: o2,
            biological_relationship: br_a
          )
        }
        let!(:ba_z_subj) {
          BiologicalAssociation.create!(
            biological_association_subject: o1,
            biological_association_object: o2,
            biological_relationship: br_z
          )
        }

        specify 'sort=biological_property_subject orders by the SubjectType property' do
          q = query.new(
            biological_association_id: [ba_z_subj.id, ba_a_subj.id],
            sort: 'biological_property_subject'
          )
          # ba_a_subj has Alpha, ba_z_subj has Zeta
          expect(q.all.map(&:id)).to eq([ba_a_subj.id, ba_z_subj.id])
        end

        specify 'sort=biological_property_object uses the ObjectType property' do
          q = query.new(
            biological_association_id: [ba_z_subj.id, ba_a_subj.id],
            sort: 'biological_property_object'
          )
          # ba_z_subj has Alpha as object, ba_a_subj has Zeta as object — reversed
          expect(q.all.map(&:id)).to eq([ba_z_subj.id, ba_a_subj.id])
        end
      end
    end
  end

end
