require 'rails_helper'
require 'support/shared_contexts/shared_geo'

# See spec/models/biological_collection_object for nested attributes and taxon determinations
describe CollectionObject, type: :model, group: [:geo, :shared_geo, :collection_objects] do
  include_context 'stuff for complex geo tests'

  context 'dwc_occurrence' do
    let(:collection_object) { CollectionObject.new() }
    specify 'saves' do
      expect(collection_object.update(total: 1)).to be_truthy
    end
  end

  context 'no dwc_occurrence' do
    let(:collection_object) { CollectionObject.new(no_dwc_occurrence: true) }
    let(:ranged_lot_category) { FactoryBot.create(:valid_ranged_lot_category) }

    context 'validation' do
      specify 'type is not set when total/ranged_lot are not provided' do
        collection_object.valid?
        expect(collection_object.type).to eq(nil)
      end

      specify 'type is set to Specimen when type not provided but total is one' do
        collection_object.total = 1
        collection_object.valid?
        expect(collection_object.type).to eq('Specimen')
      end

      specify 'type is set to Lot when type not provided but total is > 1' do
        collection_object.total = 5
        collection_object.valid?
        expect(collection_object.type).to eq('Lot')
      end

      specify 'type is set to RangedLot when type not provided but ranged_lot_id is' do
        collection_object.ranged_lot_category = FactoryBot.create(:valid_ranged_lot_category)
        collection_object.valid?
        expect(collection_object.type).to eq('RangedLot')
      end

      context 'both total and ranged_lot_category_id may not be present' do
        before {
          collection_object.total = 10
          collection_object.ranged_lot_category_id = 10
        }
        specify 'when a CollectionObject' do
          collection_object.valid?
          expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
        end

        specify 'when a Specimen' do
          collection_object.type = 'Specimen'
          collection_object.valid?
          expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
        end

        specify 'when a Lot' do
          collection_object.type = 'Lot'
          collection_object.valid?
          expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
        end

        specify 'when a RangedLot' do
          collection_object.type = 'RangedLot'
          collection_object.valid?
          expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
        end
      end

      specify 'one of total or ranged_lot_category_id must be present' do
        collection_object.valid?
        expect(collection_object.errors.include?(:base)).to be_truthy
      end

      context 'switching roles' do
        let(:s) { Specimen.create }
        let(:l) { Lot.create(total: 4) }

        specify 'a specimen when total changed to > 1 changes to a Lot' do
          s.total = 5
          s.save!
          expect(s.type).to eq('Lot')
        end

        specify 'a Lot when total changes to 1 changes to Specimen' do
          l.total = 1
          l.save!
          expect(l.type).to eq('Specimen')
        end

        specify 'a Lot when assigned a ranged lot and nilled total changes to RangedLot' do
          l.total               = nil
          l.ranged_lot_category = ranged_lot_category
          l.save!
          expect(l.type).to eq('RangedLot')
        end

        specify 'a Specimen when assigned a ranged lot and nilled total changes to RangedLot' do
          s.total               = nil
          s.ranged_lot_category = ranged_lot_category
          s.save!
          expect(s.type).to eq('RangedLot')
        end

        context 'using .update' do
          specify 'a specimen when total changed to > 1 changes to a Lot' do
            s.update!(total: 5)
            expect(s.type).to eq('Lot')
          end

          specify 'a Lot when total changes to 1 changes to Specimen' do
            l.update!(total: 1)
            expect(l.type).to eq('Specimen')
          end

          specify 'a Lot when assigned a ranged lot and nilled total changes to RangedLot' do
            l.update!(total: nil, ranged_lot_category: ranged_lot_category)
            expect(l.type).to eq('RangedLot')
          end

          specify 'a Specimen when assigned a ranged lot and nilled total changes to RangedLot' do
            s.update!(total: nil, ranged_lot_category: ranged_lot_category)
            expect(s.type).to eq('RangedLot')
          end
        end
      end
    end

    context 'via #origin_relationships' do
      specify '#extracts' do
        expect(collection_object).to respond_to(:extracts)
      end

      specify 'joins #extracts' do
        expect(CollectionObject.joins(:extracts).count).to eq(0)
      end
    end

    context 'associations' do
      context 'belongs_to' do
        specify 'preparation_type' do
          expect(collection_object.preparation_type = FactoryBot.create(:valid_preparation_type)).to be_truthy
        end

        specify 'repository' do
          expect(collection_object.repository = FactoryBot.create(:valid_repository)).to be_truthy
        end

        specify 'collecting_event' do
          expect(collection_object.collecting_event = FactoryBot.create(:valid_collecting_event)).to be_truthy
        end

        specify 'ranged_lot_category' do
          expect(collection_object.ranged_lot_category = FactoryBot.create(:valid_ranged_lot_category)).to be_truthy
        end
      end

      context 'has_many' do
        before { collection_object.total = 1 }
        # technically not supposed to have these, they are to be biological only
        specify 'taxon_determinations' do
          collection_object.taxon_determinations << FactoryBot.create(:valid_taxon_determination)
          collection_object.save!
          collection_object.reload
          expect(collection_object.taxon_determinations.first).to be_truthy
        end

        specify 'type_materials' do
          collection_object.type_materials << FactoryBot.create(:valid_type_material)
          collection_object.save!
          expect(collection_object.type_materials.count).to eq(1)
        end
      end
    end

    context 'incoming data can be stored in buffers' do
      specify 'buffered_collecting_event' do
        expect(collection_object).to respond_to(:buffered_collecting_event)
      end

      specify 'buffered_determination' do
        expect(collection_object).to respond_to(:buffered_determinations)
      end

      specify 'buffered_other_labels' do
        expect(collection_object).to respond_to(:buffered_other_labels)
      end
    end

    context 'attributes' do
      specify '#accession_provider' do
        expect(collection_object.accession_provider = FactoryBot.build(:valid_person)).to be_truthy
      end

      specify '#deaccession_recipient' do
        expect(collection_object.deaccession_recipient = FactoryBot.build(:valid_person)).to be_truthy
      end
    end

    context 'soft validation' do
      let(:o) { Specimen.new }
      let(:p) { Person.new }

      context 'accession fields are missing' do
        specify 'accessioned_at is missing' do
          o.accession_provider = p
          o.soft_validate(only_sets: :missing_accession_fields)
          expect(o.soft_validations.messages_on(:accessioned_at).count).to eq(1)
        end

        specify 'accession_recipient is missing' do
          o.accessioned_at = '12/12/2014'
          o.soft_validate(only_sets: :missing_accession_fields)
          expect(o.soft_validations.messages_on(:base).count).to eq(1)
        end

      end

      context 'deaccession fields are missing' do
        specify 'deaccession_reason is missing' do
          o.deaccessioned_at      = '12/12/2014'
          o.deaccession_recipient = p
          o.soft_validate(only_sets: :missing_deaccession_fields)
          expect(o.soft_validations.messages_on(:deaccession_reason).count).to eq(1)

        end
        specify 'deaccessioned_at is missing' do
          o.deaccession_reason = 'Because.'
          o.soft_validate(only_sets: :missing_deaccession_fields)
          expect(o.soft_validations.messages_on(:deaccessioned_at).count).to eq(1)
        end

        specify 'deaccessioned_at is missing' do
          o.deaccession_reason = 'Because.'
          o.deaccessioned_at   = '12/12/2014'
          o.soft_validate(only_sets: [:missing_deaccession_fields])
          expect(o.soft_validations.messages_on(:base).count).to eq(1)
        end
      end
    end

    context ':in_date_range' do

      describe 'various date ranges' do

        describe 'spanning a single day' do
          specify 'should find 1 record' do
            [co_m3, co_p1b].each
            collection_objects = CollectionObject.in_date_range(search_start_date: '1981-01-01',
                                                                search_end_date:   '1981-1-1')
            expect(collection_objects.map(&:collecting_event)).to contain_exactly(ce_m3)
          end
        end

        describe 'spanning a single month' do
          specify 'should find 1 record' do
            [co_m3, co_p1b].each
            collection_objects = CollectionObject.in_date_range(search_start_date: '1974-04-01',
                                                                search_end_date:   '1974-4-30')
            expect(collection_objects.map(&:collecting_event)).to contain_exactly(ce_p1b)
          end
        end

        describe 'spanning a single year' do
          specify 'should find 2 records' do
            [co_m1, co_m1a]
            collection_objects = CollectionObject.in_date_range(
              search_start_date: '1971-01-01',
              search_end_date:   '1971-12-31')
            expect(collection_objects.map(&:collecting_event)).to contain_exactly(ce_m1, ce_m1a)
          end
        end

        describe 'spanning four months of a year' do
          specify 'should find 1 record' do
            [co_m1, co_m1a].each
            collection_objects = CollectionObject.in_date_range(search_start_date: '1971-05-01',
                                                                search_end_date:   '1971-8-31')
            expect(collection_objects.map(&:collecting_event)).to contain_exactly(ce_m1a)
          end
        end

        describe 'spanning a partial year' do
          specify 'should find 2 records' do
            [co_m1, co_m1a, co_p1b].each
            collection_objects = CollectionObject.in_date_range(search_start_date: '1971-01-01',
                                                                search_end_date:   '1971-08-31')
            expect(collection_objects.map(&:collecting_event)).to contain_exactly(ce_m1, ce_m1a)
          end
        end

        describe 'spanning parts of two years' do
          specify 'should find 2 records' do
            [co_m2, co_p1b, co_m1a]
            collection_objects = CollectionObject.in_date_range(search_start_date: '1974-03-01',
                                                                 search_end_date:   '1975-06-30')
            expect(collection_objects.map(&:collecting_event)).to contain_exactly(ce_m2, ce_p1b)
          end
        end

        describe 'spanning parts of several years' do
          specify 'should find 4 records' do
            [co_n2_a, co_n2_b, co_m2, co_p1b, co_p3b].each
            collection_objects = CollectionObject.in_date_range(search_start_date: '1974-03-01',
                                                                search_end_date:   '1976-08-31')
            # expect(collection_objects.count).to eq(4)
            expect(collection_objects.map(&:collecting_event)).to contain_exactly(ce_m2, ce_p1b, ce_n2, ce_n2)
          end
        end

        describe 'excludes parts of two years in a non-greedy search for 1982-02-02-1984-09-15' do
          specify 'should find no records' do
            collection_objects = CollectionObject.in_date_range(search_start_date: '1982-02-01',
                                                                search_end_date: '1983-01-31',
                                                                partial_overlap: 'Off')
            expect(collection_objects.count).to eq(0)
            expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly()
          end
        end

        describe 'spanning parts of two years in a non-greedy search for 1982-02-02-1984-09-15' do
          specify 'should find 1 record' do
            [co_o3, co_p3b, co_m1].each
            collection_objects = CollectionObject.in_date_range(search_start_date: '1982-02-01',
                                                                search_end_date:   '1984-06-30',
                                                                partial_overlap:   'Off')
            expect(collection_objects.map(&:collecting_event)).to contain_exactly(ce_o3, ce_p3b)
          end
        end
      end
    end

    context ':from_collecting_events' do
      before {
        co_x # to create a stray collection object to _not_ be found through collecting events
        # below: each 'co_' also creates a 'ce_', the 'gr_' makes the 'co_' findable throught the 'ce_'.
        [co_n3, gr_n3, co_p1b, gr_p1b, co_o1, gr_o1,
         co_o3, co_n2_a, gr_n2_a, co_n2_b, gr_n2_b,
         co_n4, gr_n4, co_m1a, gr_m1a, co_m2, gr_m2,
         co_v, co_p2b, co_p3b, co_m3, co_n1,
         co_o2, gr_o2, co_m3, gr_m3, gr_p4s].each
      }

      describe 'all collecting events' do
        specify 'should find 15 collection objects' do
          collecting_event_ids = CollectingEvent.all.pluck(:id)
          collection_objects = CollectionObject.from_collecting_events(
            collecting_event_ids,
            [],
            false,
            project_id)
          expect(CollectionObject.count).to eq(16)
          expect(collection_objects.count).to eq(15)
        end
      end

      describe 'slice of collecting events by dates' do
        specify 'should find 9 collection objects' do
          # this is not a particular date range, but it covers collecting events which have more than one
          # collection object
          collecting_event_ids = CollectingEvent.in_date_range(search_start_date: '1970-01-01',
                                                               search_end_date:   '1979-12-31',
                                                               partial_overlap:   'on').pluck(:id)

          # equivalent to the whole world - not a very good isolation test
          area_object_ids    = CollectionObject.all.pluck(:id)
          collection_objects = CollectionObject.from_collecting_events(collecting_event_ids,
                                                                       area_object_ids,
                                                                       true,
                                                                       project_id)
          # expect(collecting_event_ids.count).to eq(9)
          expect(collection_objects.count).to eq(9)
        end
      end

      describe 'slice of collecting_events by area' do
        specify 'should find 1 collecting object' do
          area_col_event_ids = CollectingEvent.contained_within(item_r).pluck(:id) +
            (CollectingEvent.contained_within(item_s).pluck(:id))
          area_object_ids    = CollectionObject.where(collecting_event_id: area_col_event_ids).map(&:id)
          date_col_event_ids = CollectingEvent.in_date_range(search_start_date: '1970-01-01',
                                                             search_end_date:   '1982-12-31',
                                                             partial_overlap:   'off').pluck(:id)
          collection_objects = CollectionObject.from_collecting_events(date_col_event_ids,
                                                                       area_object_ids,
                                                                       false,
                                                                       project_id)
          # expect(date_col_event_ids.count).to eq(10)
          # expect(collection_objects.count).to eq(1)
          expect(collection_objects).to contain_exactly(co_m3)
        end

        specify 'should find 2 collecting objects' do
          area_col_event_ids = CollectingEvent.contained_within(item_r).pluck(:id) +
            (CollectingEvent.contained_within(item_s).pluck(:id))
          area_object_ids    = CollectionObject.where(collecting_event_id: area_col_event_ids).map(&:id)
          date_col_event_ids = CollectingEvent.in_date_range(search_start_date: '1970-01-01',
                                                             search_end_date:   '1982-12-31',
                                                             partial_overlap:   'On').pluck(:id)
          collection_objects = CollectionObject.from_collecting_events(date_col_event_ids,
                                                                       area_object_ids,
                                                                       false,
                                                                       project_id)
          expect(collection_objects).to contain_exactly(co_m3, co_n3)
        end

        specify 'should find 0 collecting objects' do
          area_col_event_ids = CollectingEvent.contained_within(item_wb).pluck(:id)
          collection_objects = CollectionObject.from_collecting_events(area_col_event_ids,
                                                                       [],
                                                                       true,
                                                                       project_id)
          expect(collection_objects.count).to eq(0)
        end
      end

      describe 'collection_objects by area' do
      end
    end

    # TODO: (Nearly) all this belongs in the Identifiers Concern specs !!!
    context 'identifier scopes, related methods' do
      let(:ns1) { FactoryBot.create(:valid_namespace) }
      let(:ns2) { FactoryBot.create(:valid_namespace) }
      let(:ns3) { FactoryBot.create(:valid_namespace) }
      let(:ns4) { FactoryBot.create(:valid_namespace) }

      let(:type_cat_no) { 'Identifier::Local::CatalogNumber' }

      let(:id_attributes) {
        { namespace:  nil,
          project_id: project_id,
          type: nil,
          identifier: nil} }

      let!(:s1) {Specimen.create}
      let!(:s2) {Specimen.create}

      let!(:i1) { 
        FactoryBot.create(
          :identifier_local_import,
          identifier_object: s1,
          identifier: 'QQQi1',
          namespace: ns3)
      }

      let!(:i2) {
        FactoryBot.create(
          :identifier_local_import,
          identifier: 'ZZZi2',
          identifier_object: s2,
          namespace: ns3
        )
      }

      (1..5).each do |identifier|
        n = "sp_#{identifier}".to_sym
        i = "id_#{identifier}".to_sym

        let!(n) {

          # Generate random ids that never duplicate
          new = true
          id = nil
          while new
            id = rand(99999) + 10 - identifier
            if !Specimen.where(id: id).any?
              new = false
            end
          end

          # Force strange id order so we don't assume anything
          Specimen.create!(id: id)
        }

        let!(i) { Identifier::Local::CatalogNumber.create!(
          identifier_object: send(n),
          namespace: (identifier.even? ? ns2 : ns1),
          identifier: identifier) }
      end

      let(:evens) { [sp_2, sp_4] }
      let(:odds) { [ sp_1, sp_3, sp_5] }

      let(:all_specimens) { [s1, s2, sp_1, sp_2, sp_3, sp_4, sp_5] }
      let(:only_numeric_identifiers) { [ sp_1, sp_2, sp_3, sp_4, sp_5] }

      specify '#next_by_identifier 1' do
        expect(sp_1.next_by_identifier).to eq(sp_3)
      end

      specify '#next_by_identifier 2' do
        expect(sp_2.next_by_identifier).to eq(sp_4)
      end

      specify '#next_by_identifier 3' do
        expect(sp_4.next_by_identifier).to eq(nil)
      end

      specify '#previous_by_identifier 1' do
        expect(sp_1.previous_by_identifier).to eq(nil)
      end

      specify '#previous_by_identifier 0' do
        expect(sp_3.previous_by_identifier).to eq(sp_1)
      end

      specify '#previous_by_identifier 2' do
        expect(sp_5.previous_by_identifier).to eq(sp_3)
      end

      specify '#previous_by_identifier 3' do
        expect(sp_4.previous_by_identifier).to eq(sp_2)
      end

      specify '#next_by_identifier, no identifier' do 
        collection_object.update!(total: 1)
        expect(collection_object.next_by_identifier).to eq(nil)
      end

      # TODO: below all generic identifier specs, move
      describe '#with_identifier_type' do
        specify 'find some which exist' do
          expect(CollectionObject.with_identifier_type(type_cat_no).count).to eq(5)
        end

        specify 'find none which do not exist' do
          expect(CollectionObject.with_identifier_type('Identifier::Local::Foo::Bar').count).to eq(0)
        end

        specify 'find some of another identifier type' do
          expect(CollectionObject.with_identifier_type('Identifier::Local::Import').count).to eq(2)
        end
      end

      describe '#with_identifier_namespace' do
        specify 'find some which exist' do
          expect(CollectionObject.with_identifier_namespace(ns1.id).count).to eq(3)
        end
      end

      describe 'with type and namespace (ns1)' do
        specify 'find some which exist' do
          expect(CollectionObject.with_identifier_type(type_cat_no)
            .with_identifier_namespace(ns1.id)).to contain_exactly(*odds)
        end
      end

      describe 'with type and namespace (ns2)' do
        specify 'find some which exist' do
          expect(CollectionObject.with_identifier_type(type_cat_no)
            .with_identifier_namespace(ns2.id)).to contain_exactly(*evens)
        end
      end

      describe 'with type and namespace (ns2) and sorted' do
        specify 'find some which exist' do
          expect(CollectionObject.with_identifier_type(type_cat_no)
            .with_identifier_namespace(ns2.id)
            .with_identifiers_sorted).to contain_exactly(*evens)
        end
      end

      describe 'with sorted identifiers' do
        specify 'without restriction' do
          expect(CollectionObject.with_identifiers_sorted.map(&:id)).to eq( only_numeric_identifiers.map(&:id) )
        end
      end

      describe 'using combo method' do
        specify 'no params' do
          expect(CollectionObject.with_identifier_type_and_namespace(nil, nil, nil).map(&:id)).to contain_exactly() # .none
        end

        specify 'with identifier_type' do
          expect(CollectionObject.with_identifier_type_and_namespace(type_cat_no).map(&:id))
            .to contain_exactly(*only_numeric_identifiers.map(&:id))
        end

        specify 'with namespace_id' do
          expect(CollectionObject.with_identifier_type_and_namespace(nil, ns2.id).map(&:id))
            .to contain_exactly(*evens.map(&:id))
        end

        # !! Only numerics included, i.e. a `where` in this sort
        specify 'with sort 1' do
          expect(CollectionObject.with_identifier_type_and_namespace(nil, nil, 'DESC').collect{|a| a.identifiers.first.identifier.to_i})
            .to eq([5,4,3,2,1])
        end

        specify 'with sort 2' do
          expect(CollectionObject.with_identifier_type_and_namespace(nil, nil, 'ASC').collect{|a| a.identifiers.first.identifier.to_i})
            .to eq([1,2,3,4,5])
        end

        specify 'with namespace_id, sort ASC' do
          expect(CollectionObject.with_identifier_type_and_namespace(nil, ns2.id, 'ASC').map(&:id) ).to eq(evens.map(&:id))
        end

        specify 'with namespace_id, sort DESC' do
          expect(CollectionObject.with_identifier_type_and_namespace(nil, ns2.id, 'DESC').map(&:id)).to eq(evens.map(&:id).reverse)
        end

        specify 'with identifier_type, namespace_id, sort DESC (all)' do
          expect(CollectionObject.with_identifier_type_and_namespace(type_cat_no, ns2.id, 'DESC').map(&:id)).to eq(evens.map(&:id).reverse)
        end

        specify 'with identifier_type, namespace_id, sort DESC (none)' do
          expect(CollectionObject.with_identifier_type_and_namespace('Some::Bad::Identifier', ns2.id, 'DESC').map(&:id)).to contain_exactly()
        end
      end
    end

    context 'used recently' do
      before { collection_object.update(total: 1) }

      let(:otu) { FactoryBot.create(:valid_otu) }
      let!(:biological_association) { FactoryBot.create(
        :valid_biological_association,
        biological_association_subject: collection_object) }
      let!(:taxon_determination) { FactoryBot.create(
        :valid_taxon_determination, otu: otu,
        biological_collection_object: collection_object) }

      specify ".used_recently('TaxonDetermination')" do
        expect(CollectionObject.used_recently(otu.created_by_id, otu.project_id,'TaxonDetermination').to_a)
          .to include(collection_object.becomes!(Specimen).id)
      end

      specify ".used_recently('BiologicalAssociation')" do
        expect(CollectionObject.used_recently(otu.created_by_id, otu.project_id,'BiologicalAssociation').to_a)
          .to include(collection_object.becomes!(Specimen).id)
      end

      specify '.selected_optimized 1' do
        expect(CollectionObject.select_optimized(
          collection_object.created_by_id,
          collection_object.project_id,
          'BiologicalAssociation'))
          .to include({recent: [collection_object.becomes!(Specimen)]})
      end

      specify '.selected_optimized 2' do
        expect(CollectionObject.select_optimized(
          collection_object.created_by_id,
          collection_object.project_id,
          'TaxonDetermination'))
          .to include({quick: [collection_object.becomes!(Specimen)]})
      end
    end

    context 'trimming fields' do
      let(:s) { " asdf sd  \n  asdfd \r\n" }
      specify '#buffered_collecting_event' do
        collection_object.buffered_collecting_event = s
        collection_object.valid?
        expect(collection_object.buffered_collecting_event).to eq(s)
      end

      specify '#buffered_determinations' do
        collection_object.buffered_determinations = s
        collection_object.valid?
        expect(collection_object.buffered_determinations).to eq(s)
      end

      specify '#buffered_other_labels' do
        collection_object.buffered_other_labels = s
        collection_object.valid?
        expect(collection_object.buffered_other_labels).to eq(s)
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'citations'
    it_behaves_like 'containable'
    it_behaves_like 'data_attributes'
    it_behaves_like 'has_roles'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end
end
