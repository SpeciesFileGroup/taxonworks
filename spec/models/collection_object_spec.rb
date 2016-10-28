require 'rails_helper'

describe CollectionObject, type: :model do

  let(:collection_object) { CollectionObject.new() }
  let(:ranged_lot_category) { FactoryGirl.create(:valid_ranged_lot_category) }

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
      collection_object.ranged_lot_category = FactoryGirl.create(:valid_ranged_lot_category)
      collection_object.valid?
      expect(collection_object.type).to eq('RangedLot')
    end

    context 'both total and ranged_lot_category_id may not be present' do
      before {
        collection_object.total = 10
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
        l.total = nil
        l.ranged_lot_category = ranged_lot_category
        l.save!
        expect(l.type).to eq('RangedLot')
      end

      specify 'a Specimen when assigned a ranged lot and nilled total changes to RangedLot' do
        s.total = nil
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
      # technically not supposed to have these, they are to be biological only 
      specify 'taxon_determinations' do
        collection_object.taxon_determinations << FactoryGirl.create(:valid_taxon_determination)
        collection_object.total = 1
        expect(collection_object.save).to be_truthy
        collection_object.reload
        expect(collection_object.taxon_determinations.first).to be_truthy
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
      s = CollectionObject.new(total: 1,
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

  context 'taxon_determinations' do

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
        o.deaccessioned_at = '12/12/2014'
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
        o.deaccessioned_at = '12/12/2014'
        o.soft_validate(:missing_deaccession_fields)
        expect(o.soft_validations.messages_on(:base).count).to eq(1)
      end
    end
  end

  context ':from_collecting_events' do
    describe 'various date ranges' do
      # let (:collecting_event_ids) {CollectingEvent.in_date_range({search_start_date: '1981/01/01', search_end_date: '1981/1/1'}).pluck(:id)}
      # let (:area_object_ids) {CollectionObject.all.pluck(:id)} # because all of the relevant collection objects created are in this area})
      before {
        generate_political_areas_with_collecting_events
      }
      after {
        clean_slate_geo
      }
# let(:params) {
#   {search_start_date: '1981/01/01',
#    search_end_date: '1981/1/1',
#    drawn_area_shape: GeographicArea
#                          .where(name: 'Great Northern Land Mass')
#                          .first
#                          .default_geographic_item
#                          .to_geo_json_feature}
# }
# it 'spans a single day' do
#   xhr(:get, :find, params)
#   result = JSON.parse(response.body)
#   expect(result['collection_objects_count']).to eq('1')
#   georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
#   expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m3')
# end
      describe 'spanning a single day' do
        specify "should find 1 record" do
          collecting_event_ids = CollectingEvent.in_date_range({search_start_date: '1981/01/01', search_end_date: '1981/1/1'}).pluck(:id)
          area_object_ids = CollectionObject.all.pluck(:id) # because all of the relevant collection objects created are in this area
          collection_objects = CollectionObject.from_collecting_events(collecting_event_ids, area_object_ids, $project_id)
          expect(collection_objects.count).to eq(1)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m3')
        end
      end
# let(:params) {
#   {search_start_date: '1974/04/01',
#    search_end_date: '1974/4/30',
#    drawn_area_shape: GeographicArea
#                          .where(name: 'Great Northern Land Mass')
#                          .first
#                          .default_geographic_item
#                          .to_geo_json_feature}
# }
# it 'spans a single month' do
#   xhr(:get, :find, params)
#   result = JSON.parse(response.body)
#   expect(result['collection_objects_count']).to eq('1')
#   georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
#   expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_p1')
# end
      describe 'spanning a single month' do
        specify "should find 1 record" do
          collecting_event_ids = CollectingEvent.in_date_range({search_start_date: '1974/04/01', search_end_date: '1974/4/30'}).pluck(:id)
          area_object_ids = CollectionObject.all.pluck(:id) # because all of the relevant collection objects created are in this area
          collection_objects = CollectionObject.from_collecting_events(collecting_event_ids, area_object_ids, $project_id)
          expect(collection_objects.count).to eq(1)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_p1')
        end
      end

#
# it 'spans a single year' do
#   let(:params) {
#     {search_start_date: '1971/01/01',
#      search_end_date: '1971/12/31',
#      drawn_area_shape: GeographicArea
#                            .where(name: 'Great Northern Land Mass')
#                            .first
#                            .default_geographic_item
#                            .to_geo_json_feature}
#   }
#   xhr(:get, :find, params)
#   result = JSON.parse(response.body)
#   expect(result['collection_objects_count']).to eq('2')
#   georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
#   expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m1')
#   georeference_id = result['feature_collection']['features'][1]['properties']['georeference']['id']
#   expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m1a')
# end
      describe 'spanning a single year' do
        specify "should find 2 records" do
          collecting_event_ids = CollectingEvent.in_date_range({search_start_date: '1971/01/01', search_end_date: '1971/12/31'}).pluck(:id)
          area_object_ids = CollectionObject.all.pluck(:id) # because all of the relevant collection objects created are in this area
          collection_objects = CollectionObject.from_collecting_events(collecting_event_ids, area_object_ids, $project_id)
          expect(collection_objects.count).to eq(2)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m1', '@ce_m1a')
        end
      end

# let (:params) {
#   {search_start_date: '1971/05/01',
#    search_end_date: '1971/8/31',
#    drawn_area_shape: GeographicArea
#                          .where(name: 'Great Northern Land Mass')
#                          .first
#                          .default_geographic_item
#                          .to_geo_json_feature}
# }
# it 'spans four months of a year' do
#   xhr(:get, :find, params)
#   result = JSON.parse(response.body)
#   expect(result['collection_objects_count']).to eq('1')
#   georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
#   expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m1a')
# end
      describe 'spanning four months of a year' do
        specify "should find 1 record" do
          collecting_event_ids = CollectingEvent.in_date_range({search_start_date: '1971/05/01', search_end_date: '1971/8/31'}).pluck(:id)
          area_object_ids = CollectionObject.all.pluck(:id) # because all of the relevant collection objects created are in this area
          collection_objects = CollectionObject.from_collecting_events(collecting_event_ids, area_object_ids, $project_id)
          expect(collection_objects.count).to eq(1)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m1a')
        end
      end
#
# let (:params) {
#   {search_start_date: '1971/01/01',
#    search_end_date: '1971/08/31',
#    drawn_area_shape: GeographicArea
#                          .where(name: 'Great Northern Land Mass')
#                          .first
#                          .default_geographic_item
#                          .to_geo_json_feature}
# }
# it 'spans a partial year' do
#   xhr(:get, :find, params)
#   result = JSON.parse(response.body)
#   expect(result['collection_objects_count']).to eq('2')
#   georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
#   expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m1')
#   georeference_id = result['feature_collection']['features'][1]['properties']['georeference']['id']
#   expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_m1a')
# end
      describe 'spanning a partial year' do
        specify "should find 2 records" do
          collecting_event_ids = CollectingEvent.in_date_range({search_start_date: '1971/01/01', search_end_date: '1971/08/31'}).pluck(:id)
          area_object_ids = CollectionObject.all.pluck(:id) # because all of the relevant collection objects created are in this area
          collection_objects = CollectionObject.from_collecting_events(collecting_event_ids, area_object_ids, $project_id)
          expect(collection_objects.count).to eq(2)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m1', '@ce_m1a')
        end
      end
#
# let (:params) {
#   {search_start_date: '1974/03/01',
#    search_end_date: '1975/6/30',
#    drawn_area_shape: GeographicArea
#                          .where(name: 'Great Northern Land Mass')
#                          .first
#                          .default_geographic_item
#                          .to_geo_json_feature}
# }
# it 'spans parts of two years' do
#   xhr(:get, :find, params)
#   result = JSON.parse(response.body)
#   expect(result['collection_objects_count']).to eq('2')
#   features          = result['feature_collection']['features']
#   georeference_id   = features[0]['properties']['georeference']['id']
#   collecting_events = [Georeference.find(georeference_id).collecting_event.verbatim_label]
#   georeference_id   = features[1]['properties']['georeference']['id']
#   collecting_events.push(Georeference.find(georeference_id).collecting_event.verbatim_label)
#   expect(collecting_events).to include('@ce_m2 in Big Boxia', '@ce_p1')
# end
      describe 'spanning parts of two years' do
        specify "should find 2 records" do
          collecting_event_ids = CollectingEvent.in_date_range({search_start_date: '1974/03/01', search_end_date: '1975/06/30'}).pluck(:id)
          area_object_ids = CollectionObject.all.pluck(:id) # because all of the relevant collection objects created are in this area
          collection_objects = CollectionObject.from_collecting_events(collecting_event_ids, area_object_ids, $project_id)
          expect(collection_objects.count).to eq(2)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m2 in Big Boxia', '@ce_p1')
        end
      end
#
# let (:params) {
#   {search_start_date: '1974/03/01',
#    search_end_date: '1976/08/31',
#    drawn_area_shape: GeographicArea
#                          .where(name: 'Great Northern Land Mass')
#                          .first
#                          .default_geographic_item
#                          .to_geo_json_feature}
# }
#
#
# it 'spans parts of several years' do
#   xhr(:get, :find, params)
#   result = JSON.parse(response.body)
#   expect(result['collection_objects_count']).to eq('4')
#   features          = result['feature_collection']['features']
#   georeference_id   = features[0]['properties']['georeference']['id']
#   collecting_events = [Georeference.find(georeference_id).collecting_event.verbatim_label]
#   georeference_id   = features[1]['properties']['georeference']['id']
#   collecting_events.push(Georeference.find(georeference_id).collecting_event.verbatim_label)
#   georeference_id = features[2]['properties']['georeference']['id']
#   collecting_events.push(Georeference.find(georeference_id).collecting_event.verbatim_label)
#   georeference_id = features[3]['properties']['georeference']['id']
#   collecting_events.push(Georeference.find(georeference_id).collecting_event.verbatim_label)
#   expect(collecting_events).to include('@ce_m2 in Big Boxia', '@ce_p1', '@ce_n2', '@ce_n2')
# end
#
      describe 'spanning parts of several years' do
        specify "should find 2 records" do
          collecting_event_ids = CollectingEvent.in_date_range({search_start_date: '1974/03/01', search_end_date: '1976/08/31'}).pluck(:id)
          area_object_ids = CollectionObject.all.pluck(:id) # because all of the relevant collection objects created are in this area
          collection_objects = CollectionObject.from_collecting_events(collecting_event_ids, area_object_ids, $project_id)
          expect(collection_objects.count).to eq(4)
          expect(collection_objects.map(&:collecting_event).map(&:verbatim_label)).to contain_exactly('@ce_m2 in Big Boxia', '@ce_p1', '@ce_n2', '@ce_n2')
        end
      end
      # # following two tests obviated by ambiguity in comparison of ranges
      # xit 'excludes parts of two years in a non-greedy search for 1982/02/02-1984/09/15' do
      #
      #   xhr(:get, :find, {search_start_date: '1982/02/01',
      #                     search_end_date: '1984/6/30',
      #                     greedy:           'off',
      #                     drawn_area_shape: GeographicArea
      #                                           .where(name: 'Great Northern Land Mass')
      #                                           .first
      #                                           .default_geographic_item
      #                                           .to_geo_json_feature})
      #   result = JSON.parse(response.body)
      #   expect(result['collection_objects_count']).to eq('0')
      # end
      #
      # let (:params) {
      #   {search_start_date: '1982/02/01',
      #    search_end_date: '1984/9/30',
      #    greedy: 'off',
      #    drawn_area_shape: GeographicArea
      #                          .where(name: 'Great Northern Land Mass')
      #                          .first
      #                          .default_geographic_item
      #                          .to_geo_json_feature}
      # }
      # xit 'spans parts of two years in a non-greedy search' do
      #   xhr(:get, :find, params)
      #   result = JSON.parse(response.body)
      #   expect(result['collection_objects_count']).to eq('1')
      #   georeference_id = result['feature_collection']['features'][0]['properties']['georeference']['id']
      #   expect(Georeference.find(georeference_id).collecting_event.verbatim_label).to eq('@ce_n3')
      # end
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
