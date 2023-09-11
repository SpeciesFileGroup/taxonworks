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

  specify '#geographic_area_id #geographic_area_mode = true (spatial) against AssertedDistribution' do
    # smaller
    a = FactoryBot.create(:level1_geographic_area)
    s1 = a.geographic_items << GeographicItem.create!(
      polygon: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )
    )

    # bigger
    b = FactoryBot.create(:level1_geographic_area)
    s2 = b.geographic_items << GeographicItem.create!(
      polygon: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 10.0, 10.0 )
    )

    # Use smaller
    AssertedDistribution.create!(otu: o2, geographic_area: a, source: FactoryBot.create(:valid_source))

    # Use bigger
    o = {
      geographic_area_id: b.id,
      geographic_area_mode: true
    }

    q = query.new(o)

    expect(q.all).to contain_exactly( ba1, ba3 )
  end


  specify '#geographic_area_id #geographic_area_mode = true (spatial) against Georeference' do
    a = FactoryBot.create(:level1_geographic_area)
    s = a.geographic_items << GeographicItem.create!(
      polygon: RspecGeoHelpers.make_polygon( RSPEC_GEO_FACTORY.point(10, 10),0,0, 5.0, 5.0 )
    )

    o3.update!(collecting_event: FactoryBot.create(:valid_collecting_event, verbatim_latitude: '7.0', verbatim_longitude: '12.0'))
    g = Georeference::VerbatimData.create!(collecting_event: o3.collecting_event)

    o = {
      geographic_area_id: a.id,
      geographic_area_mode: true
    }

    q = query.new(o)

    expect(q.all).to contain_exactly( ba2, ba3 )
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

  specify '#collecting_event_id' do
    a = BiologicalAssociation.create!(
      biological_association_subject: Specimen.create!(collecting_event: FactoryBot.create(:valid_collecting_event)),
      biological_association_object: o3,
      biological_relationship: r2)
    o = {collecting_event_id: a.biological_association_subject.collecting_event.id}
    expect(query.new(o).all.map(&:id)).to contain_exactly( a.id )
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

end
