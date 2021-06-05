require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe Queries::CollectionObject::Filter, type: :model, group: [:geo, :collection_object, :collecting_event, :shared_geo] do

  let(:query) { Queries::CollectionObject::Filter.new({}) }

  specify '#buffered_collecting_event' do
    s = FactoryBot.create(:valid_specimen, buffered_collecting_event: 'A BC D')
    query.buffered_collecting_event = 'BC'
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#exact_buffered_collecting_event 1' do
    s = FactoryBot.create(:valid_specimen, buffered_collecting_event: 'A BC D')
    query.buffered_collecting_event = 'BC'
    query.exact_buffered_collecting_event = true
    expect(query.all.pluck(:id)).to contain_exactly()
  end

  specify '#exact_buffered_collecting_event 2' do
    a = "A BC D\nE\nf"
    s = FactoryBot.create(:valid_specimen, buffered_collecting_event: a)
    query.buffered_collecting_event = a
    query.exact_buffered_collecting_event = true
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#buffered_other_labels' do
    s = FactoryBot.create(:valid_specimen, buffered_other_labels: 'A BC D')
    query.buffered_other_labels = 'BC'
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#exact_buffered_other_labels' do
    s = FactoryBot.create(:valid_specimen, buffered_other_labels: 'A BC D')
    query.buffered_other_labels = 'BC'
    query.exact_buffered_other_labels = true
    expect(query.all.pluck(:id)).to contain_exactly()
  end

  specify '#buffered_determinations' do
    s = FactoryBot.create(:valid_specimen, buffered_determinations: 'A BC D')
    query.buffered_determinations = 'BC'
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#exact_buffered_determinations' do
    s = FactoryBot.create(:valid_specimen, buffered_determinations: 'A BC D')
    query.buffered_determinations = 'BC'
    query.exact_buffered_determinations = true
    expect(query.all.pluck(:id)).to contain_exactly()
  end

  specify '#exact_buffered_collecting_event' do
    v = 'A BC D'
    s = FactoryBot.create(:valid_specimen, buffered_collecting_event: v)
    query.buffered_collecting_event = v
    query.exact_buffered_collecting_event = true
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#determiner_id' do
    FactoryBot.create(:valid_specimen)
    s = FactoryBot.create(:valid_specimen)
    FactoryBot.create(:valid_specimen) # dummy
    a = FactoryBot.create(:valid_taxon_determination, biological_collection_object: s, determiners: [ FactoryBot.create(:valid_person) ] )
    query.determiner_id = a.determiners.pluck(:id)
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#determiner_id_or (false)' do
    s = FactoryBot.create(:valid_specimen)
    p1 = FactoryBot.create(:valid_person)
    p2 = FactoryBot.create(:valid_person)

    a = FactoryBot.create(
      :valid_taxon_determination,
      biological_collection_object: s,
      determiners: [ p1, p2]
    )

    # unmatched
    s0 = FactoryBot.create(:valid_specimen) # dummy

    a = FactoryBot.create(
      :valid_taxon_determination,
      biological_collection_object: s0,
      determiners: [ p1 ]
    )

    query.determiner_id_or = false
    query.determiner_id = [p1.id, p2.id]
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#determiner_id_or (true)' do
    s = FactoryBot.create(:valid_specimen)
    p1 = FactoryBot.create(:valid_person)
    p2 = FactoryBot.create(:valid_person)

    a = FactoryBot.create(
      :valid_taxon_determination,
      biological_collection_object: s,
      determiners: [ p1, p2]
    )

    # unmatched
    s0 = FactoryBot.create(:valid_specimen) # dummy

    a = FactoryBot.create(
      :valid_taxon_determination,
      biological_collection_object: s0,
      determiners: [ p1 ]
    )

    query.determiner_id_or = true
    query.determiner_id = [p1.id, p2.id]
    expect(query.all.pluck(:id)).to contain_exactly(s.id, s0.id)
  end

  specify '#geographic_area' do
    s = FactoryBot.create(:valid_specimen, collecting_event: FactoryBot.create(:valid_collecting_event, geographic_area_id: nil))
    query.geographic_area = true
    expect(query.all.pluck(:id)).to contain_exactly()
  end

  specify '#geographic_area 1' do
    s = FactoryBot.create(:valid_specimen, collecting_event: FactoryBot.create(:valid_collecting_event, geographic_area: FactoryBot.create(:valid_geographic_area) ))
    query.geographic_area = true
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#identifiers' do
    s = FactoryBot.create(:valid_specimen)
    d = FactoryBot.create(:valid_identifier, identifier_object: s)
    query.identifiers = false
    expect(query.all.pluck(:id)).to contain_exactly()
  end

  specify '#identifiers 1' do
    FactoryBot.create(:valid_specimen)
    s = FactoryBot.create(:valid_specimen)
    d = FactoryBot.create(:valid_identifier, identifier_object: s)
    query.identifiers = true
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#collecting_event' do
    s = FactoryBot.create(:valid_specimen)
    query.collecting_event = false
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#collecting_event 1' do
    s = FactoryBot.create(:valid_specimen, collecting_event: FactoryBot.create(:valid_collecting_event))
    query.collecting_event = true
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#repository 1' do
    s = FactoryBot.create(:valid_specimen, repository: FactoryBot.create(:valid_repository))
    FactoryBot.create(:valid_specimen)
    query.repository = true
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#repository' do
    s = FactoryBot.create(:valid_specimen)
    query.repository = false
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#taxon_determinations' do
    s = FactoryBot.create(:valid_specimen)
    d = FactoryBot.create(:valid_taxon_determination, biological_collection_object: s)
    query.taxon_determinations = false
    expect(query.all.pluck(:id)).to contain_exactly()
  end

  specify '#georeferences' do
    s = FactoryBot.create(:valid_specimen, collecting_event: FactoryBot.create(:valid_collecting_event))
    d = FactoryBot.create(:valid_georeference, collecting_event: s.collecting_event)
    query.georeferences = false
    expect(query.all.pluck(:id)).to contain_exactly()
  end

  context 'simple' do
    let(:params) { {} }

    let(:ce1) { CollectingEvent.create(
      verbatim_locality: 'Out there',
      start_date_year: 2010,
      start_date_month: 2,
      start_date_day: 18) }

    let(:ce2) { CollectingEvent.create(
      verbatim_locality: 'Out there, under the stars',
      verbatim_trip_identifier: 'Foo manchu',
      start_date_year: 2000,
      start_date_month: 2,
      start_date_day: 18,
      print_label: 'THERE: under the stars:18-2-2000',
    ) }

    let!(:co1) { Specimen.create!(
      collecting_event: ce1,
      created_at: '2000-01-01',
      updated_at: '2001-01-01'
    ) }

    let!(:co2) { Lot.create!(
      total: 2,
      collecting_event: ce2,
      created_at: '2015-01-01',
      updated_at: '2015-01-01'
    ) }

    # let!(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'Foo') }
    # let!(:i1) { Identifier::Local::TripCode.create!(identifier_object: ce1, identifier: '123', namespace: namespace) }
    # let(:p1) { FactoryBot.create(:valid_person, last_name: 'Smith') }

    specify '#depictions' do
     t = FactoryBot.create(:valid_depiction, depiction_object: co1)
      query.depictions = true
      expect(query.all.pluck(:id)).to contain_exactly(co1.id)
    end

    specify '#sled_image_id' do
      m =  {
        "index": 0,
        "upperCorner": {"x":0, "y":0},
        "lowerCorner": {"x":2459.5, "y":1700.75},
        "row": 0,
        "column": 0
      }

      t = SledImage.create!(image: FactoryBot.create(:valid_image), metadata: [ m ], collection_object_params: {total: 1})

      query.sled_image_id = t.id
      expect(query.all.map.size).to eq(1)
    end

    specify '#collection_object_type' do
      query.collection_object_type = 'Lot'
      expect(query.all.pluck(:id)).to contain_exactly(co2.id)
    end

    specify '#collecting_event_query' do
      expect(query.collecting_event_query.class.name).to eq('Queries::CollectingEvent::Filter')
    end

    specify '#recent' do
      query.recent = true
      expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
    end

    specify '#collecting_event_ids' do
      query.collecting_event_ids = [ce1.id]
      params.merge!({recent: true})
      expect(query.all.pluck(:id)).to contain_exactly(co1.id)
    end

    context 'determinations, types and hierarchical search' do
      let!(:co3) { Specimen.create! } # only determination

      let!(:root) { FactoryBot.create(:root_taxon_name) }
      let!(:genus1) { Protonym.create!(name: 'Aus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }
      let!(:genus2) { Protonym.create!(name: 'Bus', parent: root, rank_class: Ranks.lookup(:iczn, :genus)) }  # synonym

      let!(:species1) { Protonym.create!(name: 'cus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species)) }
      let!(:species2) { Protonym.create!(name: 'dus', parent: genus1, rank_class: Ranks.lookup(:iczn, :species)) } # synonym

      let!(:tn1) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
        subject_taxon_name: species2, object_taxon_name: species1) }

      let!(:tn2) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
        subject_taxon_name: genus2, object_taxon_name: genus1) }

      let!(:o1) { Otu.create!(taxon_name: species1) } # valid    parent genus1
      let!(:o2) { Otu.create!(taxon_name: species2) } # invalid, parent genus1
      let!(:o3) { Otu.create!(taxon_name: genus1) }   # valid

      let!(:o4) { Otu.create!(taxon_name: genus2) }   # invalid

      let!(:td1) { FactoryBot.create(:valid_taxon_determination, biological_collection_object: co1, otu: o1) } # historical
      let!(:td2) { FactoryBot.create(:valid_taxon_determination, biological_collection_object: co1, otu: o2) } # current

      let!(:td3) { FactoryBot.create(:valid_taxon_determination, biological_collection_object: co2, otu: o2) } # historical
      let!(:td4) { FactoryBot.create(:valid_taxon_determination, biological_collection_object: co2, otu: o1) } # current

      let!(:td5) { FactoryBot.create(:valid_taxon_determination, biological_collection_object: co3, otu: o3) } # current

      context 'type specimens' do
        let!(:tm1) { TypeMaterial.create!(collection_object: co1, protonym: species1, type_type: 'holotype') }
        let!(:tm2) { TypeMaterial.create!(collection_object: co3, protonym: species2, type_type: 'neotype') }

        specify '#type_specimen_taxon_name_id' do
          query.type_specimen_taxon_name_id = species1.id
          expect(query.all.pluck(:id)).to contain_exactly(co1.id)
        end

        specify '#type_type (1)' do
          query.is_type = ['holotype']
          expect(query.all.pluck(:id)).to contain_exactly(co1.id)
        end

        specify '#type_type (2)' do
          query.is_type = ['holotype', 'neotype']
          expect(query.all.pluck(:id)).to contain_exactly(co1.id, co3.id)
        end
      end

      specify 'all specimens ever determined as an Otu' do
        # current_deteriminations = nil
        query.otu_ids = [o1.id]
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
      end

      specify 'all specimens of a given Otu currently determined as' do
        query.otu_ids = [o1.id]
        query.current_determinations = true
        expect(query.all.pluck(:id)).to contain_exactly(co2.id)
      end

      specify 'all specimens of a given Otu, historically (EXCLUDES current) determined as' do
        query.otu_ids = [o1.id]
        query.current_determinations = false
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end

      # Redundant array test
      specify 'when I ask for all specimens of several Otus, currently determined as' do
        query.otu_ids = [o1.id, o2.id ]
        query.current_determinations = true
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
      end

      specify 'when I ask for all specimens nested in a TaxonName regardless of status' do
        query.ancestor_id = genus1.id
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id, co3.id ) # anything determined as o3, o1, o2
      end

      specify 'when I ask for all specimens nested in a TaxonName, valid only' do
        query.ancestor_id = genus1.id
        query.validity = true
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id, co3.id) # anything determined as o3, o1
      end

      specify 'when I ask for all specimens nested in a TaxonName, invalid only' do
        query.ancestor_id = genus1.id
        query.validity = false
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id) # anything determined as o2
      end

      specify 'when I ask for all specimens nested in a TaxonName, valid and current' do
        query.ancestor_id = genus1.id
        query.validity = true
        query.current_determinations = true
        expect(query.all.pluck(:id)).to contain_exactly(co2.id, co3.id)
      end

      specify 'when I ask for all specimens nested in a TaxonName, invalid only, current' do
        query.ancestor_id = genus1.id
        query.validity = false
        query.current_determinations = true
        expect(query.all.pluck(:id)).to contain_exactly(co1.id) # anything determined as o3, o1, and historical
      end

      specify 'when I ask for all specimens nested in a TaxonName, invalid only, current' do
        query.ancestor_id = genus1.id
        query.validity = false
        query.current_determinations = false
        expect(query.all.pluck(:id)).to contain_exactly(co2.id) # anything determined as o2 and historical
      end
    end

    # Collecting event
    # Only a couple of each are included to test the merge, the rest are in
    #
    # And clauses

    specify '#collector_id' do
      c = CollectingEvent.create!(collectors_attributes: [{last_name: 'Jones'}], verbatim_locality: 'Urbana')
      s = Specimen.create!(collecting_event: c)
      s2 = Specimen.create! # dummy to exclude
      query.collecting_event_query.collector_id = c.collectors.reload.pluck(:id)
      expect(query.all.pluck(:id)).to contain_exactly(s.id)
    end

    specify '#geographic_area_id' do
      ce1.update(geographic_area: FactoryBot.create(:valid_geographic_area))
      query.collecting_event_query.geographic_area_id = [ce1.geographic_area.id]
      expect(query.all.pluck(:id)).to contain_exactly(co1.id)
    end

    specify '#verbatim_locality (partial)' do
      query.collecting_event_query.verbatim_locality = 'Out there'
      query.collecting_event_query.collecting_event_wildcards = ['verbatim_locality']
      expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
    end

    specify '#verbatim_locality (exact)' do
      query.collecting_event_query.verbatim_locality = 'Out there, under the stars'
      expect(query.all.pluck(:id)).to contain_exactly(co2.id)
    end

    specify '#start_date/#end_date' do
      query.collecting_event_query.start_date = '1999-1-1'
      query.collecting_event_query.end_date = '2001-1-1'
      expect(query.all.pluck(:id)).to contain_exactly(co2.id)
    end

    context 'biological_relationships' do
      let!(:co3) { Specimen.create! }
      let!(:br) { FactoryBot.create(:valid_biological_association, biological_association_subject: co1) }

      specify '#biological_relationship_ids' do
        query.biological_relationship_ids = [ br.biological_relationship_id ]
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end
    end

    context 'biocuration' do
      let!(:bc1) { FactoryBot.create(:valid_biocuration_classification, biological_collection_object: co1) }

      specify '#biocuration_class_ids' do
        query.biocuration_class_ids = [ co1.biocuration_classes.first.id ]
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end

      specify '#biocuration_class_ids + not bio' do
        query.biocuration_class_ids = [ co1.biocuration_classes.first.id ]
        query.loaned = false
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end
    end

    specify '#dwc_indexed 1' do
      query.dwc_indexed = true
      expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id) # created by default
    end

    specify '#dwc_indexed 2' do
      co1.set_dwc_occurrence
      query.dwc_indexed = false
      expect(query.all.pluck(:id)).to contain_exactly()
    end

    context 'loans' do
      let!(:li1) { FactoryBot.create(:valid_loan_item, loan_item_object: co1) }

      specify '#loaned' do
        query.loaned = true
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end

      specify '#on_loan' do
        query.on_loan = true
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end

      specify '#never_loaned' do
        query.never_loaned = true
        expect(query.all.pluck(:id)).to contain_exactly(co2.id)
      end
    end

    # Merge clauses
    context 'merge' do
      let(:factory_point) { RSPEC_GEO_FACTORY.point('10.0', '10.0') }
      let(:geographic_item) { GeographicItem::Point.create!( point: factory_point ) }

      let!(:point_georeference) {
        Georeference::VerbatimData.create!(
          collecting_event: ce1,
          geographic_item: geographic_item,
        )
      }

      let(:wkt_point) { 'POINT (10.0 10.0)'}

      specify '#wkt (POINT)' do
        query.collecting_event_query.wkt = wkt_point
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end
    end

    context 'identifiers' do
      let!(:n1) { Namespace.create!(name: 'First', short_name: 'second')}
      let!(:n2) { Namespace.create!(name: 'Third', short_name: 'fourth')}

      let!(:i1) { Identifier::Local::CatalogNumber.create!(namespace: n1, identifier: '123', identifier_object: co1) }
      let!(:i2) { Identifier::Local::CatalogNumber.create!(namespace: n2, identifier: '453', identifier_object: co2) }

      specify '#namespace_id' do
        query.namespace_id = n1.id
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end

      specify 'range 1' do
        query.identifier_start = '123'
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end

      specify 'range 2' do
        query.identifier_start = '120'
        query.identifier_end = '200'
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end

      specify 'range 3' do
        query.identifier_start = '120'
        query.identifier_end = '453'
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
      end

      specify 'range 4' do
        query.namespace_id = n2.id
        query.identifier_start = '120'
        query.identifier_end = '457'
        expect(query.all.pluck(:id)).to contain_exactly(co2.id)
      end

      specify 'range 5' do
        query.namespace_id = 999
        query.identifier_start = '120'
        query.identifier_end = '457'
        expect(query.all.pluck(:id)).to contain_exactly()
      end

      specify '#identifier_exact 1' do
        query.identifier_exact = true
        query.identifier = i2.cached
        expect(query.all.pluck(:id)).to contain_exactly(co2.id)
      end

      specify '#identifier_exact 2' do
        query.identifier_exact = false
        query.identifier = '1'
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end
    end

    # Concerns

    specify '#tags on collecting_event' do
      t = FactoryBot.create(:valid_tag, tag_object: ce1)
      query.collecting_event_query.keyword_id_and = [t.keyword_id]
      expect(query.all.pluck(:id)).to contain_exactly(co1.id)
    end

    specify '#tags on collection_object 2' do
      t = FactoryBot.create(:valid_tag, tag_object: co1)
      p = {keyword_id_and: [t.keyword_id]}
      q = Queries::CollectionObject::Filter.new(p)
      expect(q.all.pluck(:id)).to contain_exactly(co1.id)
    end

    specify '#keyword_id_and' do
      t = FactoryBot.create(:valid_tag, tag_object: co1)
      query.keyword_id_and = [t.keyword.id]
      expect(query.all.pluck(:id)).to contain_exactly(co1.id)
    end

    # See spec/lib/queries/person/filter_spec.rb for specs.
    specify 'user hooks' do
      query.user_id = Current.user_id
      expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
    end

  end

  # context 'with properly built collection of objects' do
  #   include_context 'stuff for complex geo tests'

  #   before { [co_a, co_b, gr_a, gr_b].each }

#   context 'area search' do
#     context 'named area' do
#       let(:params) { {geographic_area_ids: [area_e.id]} }

#       specify 'collection objects count' do
#         result = Queries::CollectionObject::Filter.new(params).all
#         expect(result.count).to eq(2)
#       end

#       specify 'specific collection objects' do
#         result = Queries::CollectionObject::Filter.new(params).all
#         expect(result).to include(
#           abra.collection_objects.first,
#           nuther_dog.collection_objects.first)
#       end
#     end

#     # context 'area shapes' do
#     #   context 'area shape area b' do
#     #     let(:params) { {drawn_area_shape: area_b.to_geo_json_feature} }

#     #     specify 'collection objects count' do
#     #       result = Queries::CollectionObject::Filter.new(params).all
#     #       expect(result.count).to eq(1)
#     #     end

#     #     specify 'specific collection objects' do
#     #       result = Queries::CollectionObject::Filter.new(params).all
#     #       expect(result).to include(spooler.collection_objects.first)
#     #     end
#     #   end

#     #   context 'area shape area a' do
#     #     let(:params) { {drawn_area_shape: area_a.to_geo_json_feature} }

#     #     specify 'collection objects count' do
#     #       result = Queries::CollectionObject::Filter.new(params).all
#     #       expect(result.count).to eq(1)
#     #     end

#     #     specify 'specific collection objects' do
#     #       result = Queries::CollectionObject::Filter.new(params).all
#     #       expect(result).to include(otu_a.collection_objects.first)
#     #     end
#     #   end
#     # end
#   end


  # context 'combined search' do
  #   let!(:pat_admin) {
  #     peep = FactoryBot.create(:valid_user, name: 'Pat Project Administrator', by: joe)
  #     ProjectMember.create!(project: geo_project, user: peep, by: joe)
  #     peep
  #   }
  #   let!(:pat) {
  #     peep = FactoryBot.create(:valid_user, name: 'Pat The Other', by: joe)
  #     ProjectMember.create!(project: geo_project, user: peep, by: joe)
  #     peep
  #   }
  #   let!(:joe) { User.find(1) }
  #   let!(:joe2) {
  #     peep = FactoryBot.create(:valid_user, name: 'Joe Number Two', by: joe)
  #     ProjectMember.create!(project: geo_project, user: peep, by: joe)
  #     peep
  #   }

  #   specify 'selected object' do
  #     c_objs = [co_a, co_b]

  #     # Specimen creation/update dates and Identifier/namespace
  #     2.times { FactoryBot.create(:valid_namespace, creator: geo_user, updater: geo_user) }
  #     ns1 = Namespace.first
  #     ns2 = Namespace.second
  #     2.times { FactoryBot.create(:valid_specimen, creator: pat_admin, updater: pat_admin, project: geo_project) }
  #     c_objs.each_with_index { |sp, index|
  #       sp.update_column(:created_by_id, (index.odd? ? joe.id : pat.id))
  #       sp.update_column(:created_at, "200#{index}/01/#{index + 1}")
  #       sp.update_column(:updated_at, "200#{index}/07/#{index + 1}")
  #       sp.update_column(:updated_by_id, (index.odd? ? pat.id : joe.id))
  #       sp.update_column(:project_id, geo_project.id)
  #       sp.save!
  #       FactoryBot.create(:identifier_local_catalog_number,
  #                         updater:           geo_user,
  #                         project:           geo_project,
  #                         creator:           geo_user,
  #                         identifier_object: sp,
  #                         namespace:         (index.even? ? ns1 : ns2),
  #                         identifier:        (index + 1).to_s)
  #     }

  #     # We are expecting to get only one collection_object, the one from QTM2
  #     # when this test is run along with all the rest, there are otus which have been deleted, but are still attached
  #     # to collection objects. As a result, we select the *last* one (the one *most recently* created),
  #     # rather than the first.
  #     ot        = co_b.otus.order(:id).last
  #     tn        = ot.taxon_name
  #     test_name = tn.name
  #     params    = {}
  #     params.merge!({otu_id: ot.id})
  #     params.merge!({user:                  joe,
  #                    date_type_select:      'created_at',
  #                    user_date_range_start: '2001-01-01',
  #                    user_date_range_end:   '2004-02-01'
  #                   })
  #     params.merge!({id_namespace:   ns2.short_name,
  #                    id_range_start: '2',
  #                    id_range_stop:  '8'
  #                   })
  #     params.merge!({geographic_area_ids: [area_b.id]})
  #    # params.merge!({search_start_date: '1970-01-01', search_end_date: '1986-12-31'})

  #     result = Queries::CollectionObject::Filter.new(params).all
  #     expect(result).to contain_exactly(co_b)
  #     expect(result.first.otus.count).to eq(3)
  #     expect(result.first.otus.order(:id).last.taxon_name.name).to eq(test_name)
  #   end

  # end
  # end
end

