require 'rails_helper'

describe CollectionObject, type: :model, group: [:geo, :collection_objects] do

  let(:collection_object) { CollectionObject.new() }
  let(:ranged_lot_category) { FactoryGirl.create(:valid_ranged_lot_category) }

  context 'validation' do
    specify '.valid_new_object_classes' do
      expect(CollectionObject.valid_new_object_classes).to contain_exactly('CollectionObject', 'Extract')
    end

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
      collection_object.ranged_lot_category = FactoryGirl.create(:valid_ranged_lot_category)
      collection_object.valid?
      expect(collection_object.type).to eq('RangedLot')
    end

    context 'both total and ranged_lot_category_id may not be present' do
      before {
        collection_object.total                  = 10
        collection_object.ranged_lot_category_id = 10
      }
      specify 'when a CollectionObject' do
        expect(collection_object.valid?).to be_falsey
        expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
      end

      specify 'when a Specimen' do
        collection_object.type = 'Specimen'
        expect(collection_object.valid?).to be_falsey
        expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
      end

      specify 'when a Lot' do
        collection_object.type = 'Lot'
        expect(collection_object.valid?).to be_falsey
        expect(collection_object.errors.include?(:ranged_lot_category_id)).to be_truthy
      end

      specify 'when a RangedLot' do
        collection_object.type = 'RangedLot'
        expect(collection_object.valid?).to be_falsey
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
          s.update(total: 5)
          expect(s.type).to eq('Lot')
        end

        specify 'a Lot when total changes to 1 changes to Specimen' do
          l.update(total: 1)
          expect(l.type).to eq('Specimen')
        end

        specify 'a Lot when assigned a ranged lot and nilled total changes to RangedLot' do
          l.update(total: nil, ranged_lot_category: ranged_lot_category)
          expect(l.type).to eq('RangedLot')
        end

        specify 'a Specimen when assigned a ranged lot and nilled total changes to RangedLot' do
          s.update(total: nil, ranged_lot_category: ranged_lot_category)
          expect(s.type).to eq('RangedLot')
        end
      end
    end
  end

  context '#origin_relationships' do
    specify '#derived_extracts' do
      expect(collection_object).to respond_to(:derived_extracts)
    end

    specify 'joins #derived_extracts' do
      expect(CollectionObject.joins(:derived_extracts).count).to eq(0)
    end
  end

  context 'after save' do
    let!(:c) { Delayed::Job.count }
    context 'without no_cached = true' do
      before { Specimen.create! } 
      specify 'a delayed_job is added' do
        expect(Delayed::Job.count).to eq(c + 1)
      end
    end

    context 'with no_cached = true' do
      before { Specimen.create!(no_cached: true) } 
      specify 'a delayed_job not added' do
        expect(Delayed::Job.count).to eq(c )
      end
    end
  end

  context 'associations' do
    context 'belongs_to' do
      specify 'preparation_type' do
        expect(collection_object.preparation_type = FactoryGirl.create(:valid_preparation_type)).to be_truthy
      end

      specify 'repository' do
        expect(collection_object.repository = FactoryGirl.create(:valid_repository)).to be_truthy
      end

      specify 'collecting_event' do
        expect(collection_object.collecting_event = FactoryGirl.create(:valid_collecting_event)).to be_truthy
      end

      specify 'ranged_lot_category' do
        expect(collection_object.ranged_lot_category = FactoryGirl.create(:valid_ranged_lot_category)).to be_truthy
      end
    end

    context 'has_many' do
      before {collection_object.total = 1}
      # technically not supposed to have these, they are to be biological only
      specify 'taxon_determinations' do
        collection_object.taxon_determinations << FactoryGirl.create(:valid_taxon_determination)
        expect(collection_object.save).to be_truthy
        collection_object.reload
        expect(collection_object.taxon_determinations.first).to be_truthy
      end

      specify 'type_designations' do
        expect(collection_object.type_designations << FactoryGirl.create(:valid_type_material)).to be_truthy
        expect(collection_object.save).to be_truthy
        expect(collection_object.type_designations.count).to eq(1)
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
    # xspecify "destroyed? (gone, for real, never ever EVER coming back)"
    # xspecify "condition (damaged/level)"

    specify '#accession_provider' do
      expect(collection_object.accession_provider = FactoryGirl.build(:valid_person)).to be_truthy
    end

    specify '#deaccession_recipient' do
      expect(collection_object.deaccession_recipient = FactoryGirl.build(:valid_person)).to be_truthy
    end
  end

  context 'nested attributes' do
    specify 'a new otu and determination can be created' do
      s = CollectionObject.new(total:                           1,
                               taxon_determinations_attributes: [
                                                                  {otu_attributes: {name: 'King Kong'}}
                                                                ]
      )

      expect(s.save).to be_truthy
      expect(s.taxon_determinations.count).to eq(1)
      expect(s.taxon_determinations.first.otu.name).to eq('King Kong')
      expect(s.taxon_determinations.first.otu.id).to be_truthy
    end
  end

  context 'soft validation' do
    let(:o) { Specimen.new }
    let(:p) { Person.new }

    context 'accession fields are missing' do
      specify 'accessioned_at is missing' do
        o.accession_provider = p
        o.soft_validate(:missing_accession_fields)
        expect(o.soft_validations.messages_on(:accessioned_at).count).to eq(1)
      end

      specify 'accession_recipient is missing' do
        o.accessioned_at = '12/12/2014'
        o.soft_validate(:missing_accession_fields)
        expect(o.soft_validations.messages_on(:base).count).to eq(1)
      end

    end

    context 'deaccession fields are missing' do
      specify 'deaccession_reason is missing' do
        o.deaccessioned_at      = '12/12/2014'
        o.deaccession_recipient = p
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:deaccession_reason).count).to eq(1)

      end
      specify 'deaccessioned_at is missing' do
        o.deaccession_reason = 'Because.'
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:deaccessioned_at).count).to eq(1)
      end

      specify 'deaccessioned_at is missing' do
        o.deaccession_reason = 'Because.'
        o.deaccessioned_at   = '12/12/2014'
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:base).count).to eq(1)
      end
    end
  end

  context ':in_date_range' do
    describe 'various date ranges' do
      # let (:collecting_event_ids) {CollectingEvent.in_date_range({search_start_date: '1981/01/01', search_end_date: '1981/1/1'}).pluck(:id)}
      # let (:area_object_ids) {CollectionObject.all.pluck(:id)} # because all of the relevant collection objects created are in this area})
      before(:all) {
        generate_political_areas_with_collecting_events
      }
      after(:all) {
        clean_slate_geo
      }
      
      describe 'spanning a single day' do
        specify "should find 1 record" do
          collection_objects = CollectionObject.in_date_range({search_start_date: '1981/01/01', search_end_date: '1981/1/1'})
          expect(collection_objects.count).to eq(1)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m3')
        end
      end

      describe 'spanning a single month' do
        specify "should find 1 record" do
          collection_objects = CollectionObject.in_date_range({search_start_date: '1974/04/01', search_end_date: '1974/4/30'})
          expect(collection_objects.count).to eq(1)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_p1')
        end
      end

      describe 'spanning a single year' do
        specify "should find 2 records" do
          collection_objects = CollectionObject.in_date_range({search_start_date: '1971/01/01', search_end_date: '1971/12/31'})
          expect(collection_objects.count).to eq(2)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m1', '@ce_m1a')
        end
      end

      describe 'spanning four months of a year' do
        specify "should find 1 record" do
          collection_objects = CollectionObject.in_date_range({search_start_date: '1971/05/01', search_end_date: '1971/8/31'})
          expect(collection_objects.count).to eq(1)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m1a')
        end
      end

      describe 'spanning a partial year' do
        specify "should find 2 records" do
          collection_objects = CollectionObject.in_date_range({search_start_date: '1971/01/01', search_end_date: '1971/08/31'})
          expect(collection_objects.count).to eq(2)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m1', '@ce_m1a')
        end
      end

      describe 'spanning parts of two years' do
        specify "should find 2 records" do
          collection_objects = CollectionObject.in_date_range({search_start_date: '1974/03/01', search_end_date: '1975/06/30'})
          expect(collection_objects.count).to eq(2)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m2 in Big Boxia', '@ce_p1')
        end
      end

      describe 'spanning parts of several years' do
        specify "should find 4 records" do
          collection_objects = CollectionObject.in_date_range({search_start_date: '1974/03/01', search_end_date: '1976/08/31'})
          expect(collection_objects.count).to eq(4)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m2 in Big Boxia', '@ce_p1', '@ce_n2', '@ce_n2')
        end
      end

      describe 'excludes parts of two years in a non-greedy search for 1982/02/02-1984/09/15' do
        specify 'should find no records' do
          collection_objects = CollectionObject.in_date_range({search_start_date: '1982/02/01', search_end_date: '1983/01/31', partial_overlap: 'Off'})
          expect(collection_objects.count).to eq(0)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly()
        end
      end

      describe 'spanning parts of two years in a non-greedy search for 1982/02/02-1984/09/15' do
        specify 'should find 1 record' do
          collection_objects = CollectionObject.in_date_range({search_start_date: '1982/02/01', search_end_date: '1984/06/30', partial_overlap: 'Off'})
          expect(collection_objects.count).to eq(2)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_o3',
                                                                                                      '@ce_p3')
        end
      end
    end
  end

  context ':from_collecting_events' do
    before(:all) {
      generate_political_areas_with_collecting_events
    }
    after(:all) {
      clean_slate_geo
    }
    describe 'all collecting events' do
      specify 'should find 19 collection objects' do
        collecting_event_ids = CollectingEvent.all.pluck(:id)
        collection_objects   = CollectionObject.from_collecting_events(collecting_event_ids, [], false, $project_id)
        expect(CollectionObject.count).to eq(20)
        expect(collection_objects.count).to eq(19)
      end
    end

    describe 'slice of collecting events by dates' do
      specify 'should find 10 collection objects' do
        # this is not a particular date range, but it covers collecting events which have more than one
        # collection object
        collecting_event_ids = CollectingEvent.in_date_range({search_start_date: '1970/01/01', search_end_date: '1979/12/31', partial_overlap: 'on'}).pluck(:id)
        area_object_ids = CollectionObject.all.pluck(:id) # equivalent to the whole world - not a very good isolation test
        collection_objects   = CollectionObject.from_collecting_events(collecting_event_ids,
                                                                       area_object_ids,
                                                                       true,
                                                                       $project_id)
        expect(collecting_event_ids.count).to eq(9)
        expect(collection_objects.count).to eq(10)
      end
    end

    describe 'slice of collecting_events by area' do
      specify 'should find 1 collecting object' do
        collecting_event_ids = CollectingEvent.contained_within(@item_r).pluck(:id) + (CollectingEvent.contained_within(@item_s).pluck(:id))
        area_object_ids      = CollectionObject.where(collecting_event_id: collecting_event_ids).map(&:id)
        collecting_event_ids = CollectingEvent.in_date_range({search_start_date: '1970/01/01', search_end_date: '1982/12/31', partial_overlap: 'off'}).pluck(:id)
        collection_objects   = CollectionObject.from_collecting_events(collecting_event_ids,
                                                                       area_object_ids,
                                                                       false,
                                                                       $project_id)
        expect(collecting_event_ids.count).to eq(10)
        expect(collection_objects.count).to eq(1)
        found_c_os = [@co_m3]
        found_c_os.each_with_index { |c_o, index|
          expect(collection_objects[index].metamorphosize).to eq(c_o)
        }
      end

      specify 'should find 2 collecting objects' do
        collecting_event_ids = CollectingEvent.contained_within(@item_r).pluck(:id) + (CollectingEvent.contained_within(@item_s).pluck(:id))
        area_object_ids = CollectionObject.where(collecting_event_id: collecting_event_ids).map(&:id)
        collecting_event_ids = CollectingEvent.in_date_range({search_start_date: '1970/01/01', search_end_date: '1982/12/31', partial_overlap: 'On'}).pluck(:id)
        collection_objects = CollectionObject.from_collecting_events(collecting_event_ids,
                                                                     area_object_ids,
                                                                     false,
                                                                     $project_id)
        expect(collecting_event_ids.count).to eq(11)
        expect(collection_objects.count).to eq(2)
        found_c_os = [@co_m3, @co_n3]
        collection_objects.each_with_index { |c_o, index|
          collection_objects[index] = collection_objects[index].metamorphosize
        }
        expect(collection_objects).to contain_exactly(*found_c_os)
      end

      specify 'should find 0 collecting objects' do
        collecting_event_ids = CollectingEvent.contained_within(@item_wb).pluck(:id)
        collection_objects   = CollectionObject.from_collecting_events(collecting_event_ids,
                                                                       [],
                                                                       true,
                                                                       $project_id)
        expect(collecting_event_ids.count).to eq(6)
        expect(collection_objects.count).to eq(0)
      end
    end

    describe 'collection_objects by area' do
    end
  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'containable'
    it_behaves_like 'data_attributes'
    it_behaves_like 'has_roles'
    it_behaves_like 'identifiable'
    it_behaves_like 'notable'
    it_behaves_like 'taggable'
    it_behaves_like 'is_data'
  end

end
