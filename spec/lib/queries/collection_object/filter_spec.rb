require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe Queries::CollectionObject::Filter, type: :model, group: [:geo, :collection_object, :collecting_event, :shared_geo, :filter] do

  let(:query) { Queries::CollectionObject::Filter.new({}) }

  context 'housekeeping_extensions' do
    let!(:s) { Specimen.create!(updated_at: old_date, created_at: old_date) }
    let(:old_date) { 2.weeks.ago }

    # An old collecting event not hit in the params below
    let(:c) { FactoryBot.create(:valid_collecting_event, created_at: old_date, updated_at: old_date) }

    let!(:p) {
      {
        extend_housekeeping: true,
        user_date_start: 1.day.ago.to_date.to_s,
        user_date_end: DateTime.tomorrow .to_s
      }
    }
    let(:q) { Queries::CollectionObject::Filter.new(p) }

    specify 'control' do
      expect(q.all).to contain_exactly()
    end

    specify 'collecting_events' do
      d = FactoryBot.create(:valid_collecting_event)
      s.update!(collecting_event: d, updated_at: old_date) # time travel

      expect(q.all).to contain_exactly(s)
    end

    specify 'collecting_event data attributes' do
      s.update!(collecting_event: c, updated_at: old_date)
      FactoryBot.create(:valid_data_attribute, attribute_subject: c)

      expect(q.all).to contain_exactly(s)
    end

    specify 'taxon_determinations' do
      c = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s)
      expect(q.all).to contain_exactly(s)
    end

    specify 'data_attributes' do
      c = FactoryBot.create(:valid_data_attribute, attribute_subject:  s)
      expect(q.all).to contain_exactly(s)
    end

    specify 'georeferences' do
      FactoryBot.create(:valid_georeference, collecting_event: c)
      s.update!(collecting_event: c, updated_at: old_date)

      expect(q.all).to contain_exactly(s)
    end

    specify 'collecting event notes' do
      FactoryBot.create(:valid_note, note_object: c)
      s.update!(collecting_event: c, updated_at: old_date)
      expect(q.all).to contain_exactly(s)
    end

    specify 'collection_object notes' do
      FactoryBot.create(:valid_note, note_object: s)
      expect(q.all).to contain_exactly(s)
    end

    specify 'collecting_event roles' do
      FactoryBot.create(:valid_collector, role_object: c)
      s.update!(collecting_event: c, updated_at: old_date)
      expect(q.all).to contain_exactly(s)
    end

    specify 'taxon_determiner roles' do
      t = FactoryBot.create(:valid_taxon_determination, created_at: old_date, updated_at: old_date, taxon_determination_object: s) # TODO: refactor for FO
      FactoryBot.create(:valid_determiner, role_object: t)

      expect(q.all).to contain_exactly(s)
    end
  end

  context 'pagination' do
    before { 3.times { FactoryBot.create(:valid_specimen) } }

    specify 'paginate' do
      h = { paginate: nil, per: 1 }
      q = Queries::CollectionObject::Filter.new(h)
      expect(q.all.size).to eq(3) # no pagination, get everything
    end

   specify 'page 1' do
      h = { paginate: true, per: 1, page: 3}
      q = Queries::CollectionObject::Filter.new(h)
      expect(q.all.order(:id).all.last).to eq(Specimen.last)
    end

    specify 'per' do
      h = { paginate: true, per: 1 }
      q = Queries::CollectionObject::Filter.new(h)
      expect(q.all.size).to eq(1)
    end
  end

  specify 'nested pagination' do
    3.times { FactoryBot.create(:valid_specimen, collecting_event: FactoryBot.create(:valid_collecting_event) ) }

    # Get the second CE
    h = { collecting_event_query: {paginate: true, per: 1, page: 2 } }

    p = ActionController::Parameters.new(h)

    q = Queries::CollectionObject::Filter.new(p)
    expect(q.all.first).to eq(Specimen.second)
  end

  specify 'CollectingEvent params are permitted' do
    h = {geographic_area_id: 1 }
    p = ActionController::Parameters.new(h)
    q = Queries::CollectionObject::Filter.new(p)

    expect(q.base_collecting_event_query.geographic_area_id).to eq([1])
  end

  specify '#determiner_name_regex' do
    s = Specimen.create!
    a = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s, determiners: [ FactoryBot.create(:valid_person, last_name: 'Smith') ] )

    s1 = Specimen.create! # not this one
    b = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s1, determiners: [ FactoryBot.create(:valid_person, last_name: 'htims') ] )

    query.determiner_name_regex = 'i.*h'
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  context 'lib/queries/concerns/notes.rb' do
    specify '#notes present' do
      s = Specimen.create!
      Specimen.create! # not this one
      n = s.notes << Note.new(text: 'my text')
      query.notes = true
      expect(query.all.pluck(:id)).to contain_exactly(s.id)
    end

    specify '#notes absent' do
      s = Specimen.create!  # not this one
      n = Specimen.create!
      s.notes << Note.new(text: 'my text')
      query.notes = false

      expect(query.all.pluck(:id)).to contain_exactly(n.id)
    end

    specify '#note_text matches' do
      s = Specimen.create!
      Specimen.create! # not this
      s.notes << Note.new(text: 'my text')
      query.note_text = 'text'

      expect(query.all.pluck(:id)).to contain_exactly(s.id)
    end

    specify '#note_text exact matches' do
      s = Specimen.create!
      Specimen.create! # not this
      s.notes << Note.new(text: 'my text')
      query.note_text = 'text'
      query.note_exact = true

      expect(query.all.pluck(:id)).to be_empty
    end
  end

  specify '#loan_id' do
    t1 = Specimen.create!
    l = FactoryBot.create(:valid_loan)
    t2 = Specimen.create!
    l.loan_items << LoanItem.new(loan_item_object: t1)

    query.loan_id = [l.id]
    expect(query.all.pluck(:id)).to contain_exactly(t1.id)
  end

  specify '#type_designations' do
    t1 = Specimen.create!
    t2 = Specimen.create!
    s = FactoryBot.create(:valid_type_material, collection_object: t2)

    query.type_material = true
    expect(query.all.pluck(:id)).to contain_exactly(t2.id)
  end

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
    a = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s, determiners: [ FactoryBot.create(:valid_person) ] )
    query.determiner_id = a.determiners.pluck(:id)
    expect(query.all.pluck(:id)).to contain_exactly(s.id)
  end

  specify '#determiner_id_or (false)' do
    s = FactoryBot.create(:valid_specimen)
    p1 = FactoryBot.create(:valid_person)
    p2 = FactoryBot.create(:valid_person)

    a = FactoryBot.create(
      :valid_taxon_determination,
      taxon_determination_object: s,
      determiners: [ p1, p2]
    )

    # unmatched
    s0 = FactoryBot.create(:valid_specimen) # dummy

    a = FactoryBot.create(
      :valid_taxon_determination,
      taxon_determination_object: s0,
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
      taxon_determination_object: s,
      determiners: [ p1, p2]
    )

    # unmatched
    s0 = FactoryBot.create(:valid_specimen) # dummy

    a = FactoryBot.create(
      :valid_taxon_determination,
      taxon_determination_object: s0,
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

  specify '#taxon_determinations 1' do
    s = FactoryBot.create(:valid_specimen)
    d = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s)
    a = Specimen.create! # this one
    query.taxon_determinations = false
    expect(query.all.pluck(:id)).to contain_exactly(a.id)
  end

  specify '#taxon_determinations #buffered_determinations' do
    s = FactoryBot.create(:valid_specimen, buffered_determinations: 'Foo')
    d = FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s)

    a = Specimen.create!(buffered_determinations: 'Foo')  # this one

    query.taxon_determinations = false
    query.exact_buffered_determinations = true
    query.buffered_determinations = 'Foo'

    expect(query.all.pluck(:id)).to contain_exactly(a.id)
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

    specify '#images' do
      t = FactoryBot.create(:valid_depiction, depiction_object: co1)
      query.images = true
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

    specify '#base_collecting_event_query' do
      expect(query.base_collecting_event_query.class.name).to eq('Queries::CollectingEvent::Filter')
    end

    specify '#recent' do
      query.recent = true
      expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
    end

    specify '#collecting_event_id' do
      query.collecting_event_id = [ce1.id]
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

      let!(:td1) { FactoryBot.create(:valid_taxon_determination, taxon_determination_object: co1, otu: o1) } # historical
      let!(:td2) { FactoryBot.create(:valid_taxon_determination, taxon_determination_object: co1, otu: o2) } # current

      let!(:td3) { FactoryBot.create(:valid_taxon_determination, taxon_determination_object: co2, otu: o2) } # historical
      let!(:td4) { FactoryBot.create(:valid_taxon_determination, taxon_determination_object: co2, otu: o1) } # current

      let!(:td5) { FactoryBot.create(:valid_taxon_determination, taxon_determination_object: co3, otu: o3) } # current


      # collection_objects/dwc_index?&per=500&page=1&determiner_id[]=61279&taxon_name_id=606330
      specify '#determiner_id, taxon_name_id combo' do
        t1 = Specimen.create!
        t2 = Specimen.create!
        o = Otu.create!(taxon_name: species1)
        a = FactoryBot.create(:valid_taxon_determination, otu: o, taxon_determination_object: t1, determiners: [ FactoryBot.create(:valid_person) ] )

        query.determiner_id = a.determiners.pluck(:id)
        # query.collector_id_or = false
        query.taxon_name_id = genus1.id
        query.descendants = true

        expect(query.all.pluck(:id)).to contain_exactly(t1.id)
      end

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
        query.otu_id = [o1.id]
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
      end

      specify 'all specimens of a given Otu currently determined as' do
        query.otu_id = [o1.id]
        query.current_determinations = true
        expect(query.all.pluck(:id)).to contain_exactly(co2.id)
      end

      specify 'all specimens of a given Otu, historically (EXCLUDES current) determined as' do
        query.otu_id = [o1.id]
        query.current_determinations = false
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end

      # Redundant array test
      specify 'when I ask for all specimens of several Otus, currently determined as' do
        query.otu_id = [o1.id, o2.id ]
        query.current_determinations = true
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
      end

      specify 'all specimens nested in a TaxonName regardless of status' do
        query.taxon_name_id = genus1.id
        query.descendants = true
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id, co3.id ) # anything determined as o3, o1, o2
      end

      specify 'all specimens nested in a TaxonName, valid only' do
        query.taxon_name_id = genus1.id
        query.validity = true
        query.descendants = true
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id, co3.id) # anything determined as o3, o1
      end

      specify 'all specimens nested in a TaxonName, invalid only' do
        query.taxon_name_id = genus1.id
        query.validity = false
        query.descendants = true
        expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id) # anything determined as o2
      end

      specify 'all specimens nested in a TaxonName, valid and current' do
        query.taxon_name_id = genus1.id
        query.validity = true
        query.current_determinations = true
        query.descendants = true
        expect(query.all.pluck(:id)).to contain_exactly(co2.id, co3.id)
      end

      specify 'all specimens nested in a TaxonName, invalid only, current' do
        query.taxon_name_id = genus1.id
        query.validity = false
        query.current_determinations = true
        query.descendants = true
        expect(query.all.pluck(:id)).to contain_exactly(co1.id) # anything determined as o3, o1, and historical
      end

      specify 'all specimens nested in a TaxonName, invalid only, current' do
        query.taxon_name_id = genus1.id
        query.validity = false
        query.current_determinations = false
        query.descendants = true
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
      query.base_collecting_event_query.collector_id = c.collectors.reload.pluck(:id)
      expect(query.all.pluck(:id)).to contain_exactly(s.id)
    end

    specify '#geographic_area_id' do
      ce1.update(geographic_area: FactoryBot.create(:valid_geographic_area))
      query.base_collecting_event_query.geographic_area_id = [ce1.geographic_area.id]
      expect(query.all.pluck(:id)).to contain_exactly(co1.id)
    end

    specify '#verbatim_locality (partial)' do
      query.base_collecting_event_query.verbatim_locality = 'Out there'
      query.base_collecting_event_query.wildcard_attribute = ['verbatim_locality']
      expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
    end

    specify '#verbatim_locality (exact)' do
      query.base_collecting_event_query.verbatim_locality = 'Out there, under the stars'
      expect(query.all.pluck(:id)).to contain_exactly(co2.id)
    end

    specify '#start_date/#end_date' do
      query.base_collecting_event_query.start_date = '1999-1-1'
      query.base_collecting_event_query.end_date = '2001-1-1'
      expect(query.all.pluck(:id)).to contain_exactly(co2.id)
    end

    context 'biological_relationships' do
      let!(:co3) { Specimen.create! }
      let!(:br) { FactoryBot.create(:valid_biological_association, biological_association_subject: co1) }

      specify '#biological_relationship_id' do
        query.biological_relationship_id = [ br.biological_relationship_id ]
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end
    end

    context 'biocuration' do
      let!(:bc1) { FactoryBot.create(:valid_biocuration_classification, biocuration_classification_object: co1) }

      specify '#biocuration_class_id' do
        query.biocuration_class_id = [ co1.biocuration_classes.first.id ]
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end

      specify '#biocuration_class_id + not bio' do
        query.biocuration_class_id = [ co1.biocuration_classes.first.id ]
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

    specify '#dwc_indexed + date' do
      co1.set_dwc_occurrence
      query.dwc_indexed = true
      query.user_date_end = 1.day.ago.to_date.to_s
      query.user_date_start = 2.days.ago.to_date.to_s
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
          geographic_item:,
        )
      }

      let(:wkt_point) { 'POINT (10.0 10.0)'}

      specify '#wkt (POINT)' do
        query.base_collecting_event_query.wkt = wkt_point
        expect(query.all.pluck(:id)).to contain_exactly(co1.id)
      end
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
      query.user_id = user_id
      expect(query.all.pluck(:id)).to contain_exactly(co1.id, co2.id)
    end

  end
end
