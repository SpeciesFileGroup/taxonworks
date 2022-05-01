require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe Georeference, type: :model, group: [:geo, :shared_geo, :georeferences] do
  include_context 'stuff for complex geo tests'
  let(:georeference) { Georeference.new }

  let(:earth) { FactoryBot.create(:earth_geographic_area) }
  let(:g_a_t) { FactoryBot.create(:testbox_geographic_area_type) }

  let(:e_g_i) { GeographicItem.create(polygon: box_1) }
  let(:item_d) { GeographicItem.create(polygon: box_4) }

  let!(:g_a) {
    GeographicArea.create(name:                 'Box_4',
                          data_origin:          'Test Data',
                          geographic_area_type: g_a_t,
                          parent:               earth)
  }

  # this collecting event should produce a georeference.geographic_item.geo_object of 'Point(0.1 0.1 0.1)'
  let(:collecting_event_with_geographic_area) {
    CollectingEvent.create!(
      geographic_area:    g_a,
      verbatim_locality:  'Test Event',
      minimum_elevation:  0.1,
      verbatim_latitude:  '0.1',
      verbatim_longitude: '0.1')
  }

  let(:collecting_event_without_geographic_area) {
    CollectingEvent.create!(verbatim_locality: 'without geographic area')
  }

  let!(:gagi) { GeographicAreasGeographicItem.create!(geographic_item: item_d, geographic_area: g_a) }

  context 'associations' do
    context 'belongs_to' do
      specify '#geographic_item' do
        expect(georeference.geographic_item = GeographicItem.new).to be_truthy
      end

      specify '#error_geographic_item' do
        expect(georeference.error_geographic_item = GeographicItem.new).to be_truthy
      end

      specify '#collecting_event' do
        expect(georeference.collecting_event = CollectingEvent.new).to be_truthy
      end
    end
  end

  context 'georeference role' do
    let(:georeference) { FactoryBot.create(:valid_georeference) }
    specify 'with << and an existing object' do
      expect(georeference.roles.count).to eq(0)
      georeference.georeferencers << Person.new(last_name: 'Smith')
      expect(georeference.save).to be_truthy

      expect(georeference.georeferencers.first.creator.nil?).to be_falsey
      expect(georeference.georeferencers.first.updater.nil?).to be_falsey

      expect(georeference.roles.first.creator.nil?).to be_falsey
      expect(georeference.roles.first.updater.nil?).to be_falsey
    end
  end

  context 'validation' do
    before(:each) { georeference.valid?  }

    specify '#geographic_item is required' do
      expect(georeference.errors.include?(:geographic_item)).to be_truthy
    end

    # specify '#collecting_event is required' do
      # no longer true at this level: 'not null' is now enforced at the table level.
      # expect(georeference.errors.include?(:collecting_event)).to be_truthy
    # end

    specify '#type is required' do
      expect(georeference.errors.include?(:type)).to be_truthy
    end

    specify '#error_geographic_item is not required' do
      expect(georeference.errors.include?(:error_geographic_item)).to be_falsey
    end

    specify '#error_radius is not required' do
      expect(georeference.errors.include?(:error_radius)).to be_falsey
    end

    specify 'error_depth is not required' do
      expect(georeference.errors.include?(:error_depth)).to be_falsey
    end

    context 'legal values' do
      context '#error_radius' do
        before {
          georeference.geographic_item = FactoryBot.create(:valid_geographic_item)
        }

        specify 'is > some Earth-based limit' do
          # 12,400 miles, 20,000 km (an approximation of less than half of the circumference of the earth)
          # skip 'setting error radius to some reasonable distance'
          georeference.error_radius = 10_000_000
          georeference.valid?
          expect(georeference.errors[:error_radius]).to be_present
        end

        specify 'can be set to something reasonable' do
          georeference.geographic_item = GeographicItem.first
          georeference.error_radius    = 3
          georeference.valid?
          expect(georeference.errors[:error_radius]).to_not be_present
        end
      end

      specify '#error_depth is < some Earth-based limit' do
        # 8,800 meters
        georeference.error_depth = 9000
        georeference.valid?
        expect(georeference.errors[:error_depth]).to be_truthy
      end

      specify '#error_depth can be set to something reasonable' do
        georeference.error_depth = 3
        georeference.valid?
        expect(georeference.errors[:error_depth]).to_not be_present
      end

      context 'allowed combinations of values' do
        before {
          georeference.type             = 'Georeference::GoogleMap'
          georeference.collecting_event = collecting_event_without_geographic_area
        }

        specify 'geographic_item without error_radius, error_depth, or error_geographic_item' do
          georeference.geographic_item = GeographicItem.new(point: simple_shapes[:point])
          expect(georeference.valid?).to be_truthy
        end

        specify 'geographic_item with error_radius' do
          georeference.geographic_item = GeographicItem.new(point: simple_shapes[:point])
          georeference.error_radius    = 10000
          expect(georeference.valid?).to be_truthy
        end

        specify 'geographic_item with error_geographic_item' do
          georeference.geographic_item = GeographicItem.new(point: 'POINT(5 5 0)')
          georeference.geographic_item = GeographicItem.new(polygon: 'POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, ' \
                                                                      '10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0))')
          expect(georeference.valid?).to be_truthy
        end
      end
    end

    # ----------------------

    context 'geographic_item related' do
      # TODO: Remove.  The georeference should assume the geographic items handle their own error checking
      context 'malformed geographic_items' do
        specify 'errors which result from badly formed error_geographic_item values' do
          g = Georeference::VerbatimData.new(
            collecting_event: collecting_event_with_geographic_area,
            error_geographic_item: GeographicItem.new(polygon: poly_e1))
          g.valid?
          expect(g.errors[:error_geographic_item]).to be_present
          expect(g.errors[:collecting_event]).to be_present
        end
      end

      specify 'Georeference::VerbatimData #error_radius is limited to 10km error radius' do
        collecting_event_with_geographic_area.update!(verbatim_geolocation_uncertainty:  '16000m')
        g = Georeference::VerbatimData.new(
          collecting_event: collecting_event_with_geographic_area,
         #   error_radius: 16000, # NO - is taken from verbatim collecting event
          error_geographic_item: e_g_i)
        g.valid?
        expect(g.errors[:error_geographic_item]).to be_present
        expect(g.errors[:error_radius]).to be_present
      end

      context 'testing geographic_item/error against geographic area provided through collecting event' do
        let(:p0) { GeographicItem.new(point: point0) }
        let(:p18) { GeographicItem.new(point: point18) }
        let(:gi_b1) { GeographicItem.create!(polygon: shape_b_outer) }
        let(:gi_b2) { GeographicItem.create!(polygon: shape_b_inner) }
        let(:gi_e1) { GeographicItem.create!(polygon: poly_e1) }
        let(:ga_e1) {
          GeographicArea.create!(
            name:                   'test area E1',
            data_origin:            'Test Data',
            geographic_area_type:   g_a_t,
            parent:                 earth,
            geographic_areas_geographic_items_attributes: [
              {geographic_item: gi_e1,
               data_origin: 'Test Data'}]
          ) }
        let(:ga_b1) {
          GeographicArea.create!(
            name: 'test area B1',
            data_origin: 'Test Data',
            geographic_area_type: g_a_t,
            parent: earth,
            geographic_areas_geographic_items_attributes: [
              {geographic_item: gi_b1,
               data_origin: 'Test Data'}]
          ) }
        let(:ce_e1) { CollectingEvent.new(geographic_area: ga_e1) }
        let(:ce_b1) { CollectingEvent.new(geographic_area: ga_b1) }

        before {
          GeographicAreasGeographicItem.create!(geographic_area: ga_e1, geographic_item: gi_e1)
          GeographicAreasGeographicItem.create!(geographic_area: ga_b1, geographic_item: gi_b1)
        }

        specify 'errors which result from badly formed collecting_event area values and error_geographic_item' do
          # error_geographic_item exists,  but is not inside ce_e1
          g = Georeference::VerbatimData.new(
            collecting_event: ce_e1,
            # e_g_i is test_box_1
            error_geographic_item: e_g_i)
          g.valid?

          expect(g.errors[:error_geographic_item]).to be_present
          expect(g.errors[:collecting_event]).to be_present
        end

        specify 'an error is added to #geographic_item if collecting_event.geographic_area.geo_object does ' \
          'not contain #geographic_item' do
            g = Georeference::VerbatimData.new(
              collecting_event: ce_e1, # p0 is outside of both e_g_i and ce.geographic_area
              geographic_item: p0, # e_g_i is test_box_1
              error_geographic_item: e_g_i)
            g.valid?

            expect(g.errors[:geographic_item]).to be_present
          end

        specify 'an error is added to #error_geographic_item if collecting_event.geographic_area.geo_object ' \
                          'does not contain #error_geographic_item' do
          g = Georeference::VerbatimData.new(
            collecting_event: ce_e1, # p0 is outside of both e_g_i and ce.geographic_area
            geographic_item: p0, # e_g_i is test_box_1
            error_geographic_item: e_g_i)
          g.valid?

          expect(g.errors[:error_geographic_item]).to be_present
        end

        # 2c
        specify 'an error is added to error_radius when error_radius provided and geographic_item not provided' do
          g = Georeference.new(error_radius: 10)
          g.valid?
          expect(g.errors.include?(:error_radius)).to be_truthy
          expect(g.errors.messages[:error_radius]).to include('can only be provided when geographic item is provided')
        end

        # case 3
        specify 'an error is added to error_geographic_item when error_radius and point geographic_item ' \
          'do not fully contain error_geographic_item' do
            g = Georeference::GoogleMap.new(
              collecting_event: ce_b1,
              # p18 is inside of both gi_b2 and ce_b1
              geographic_item: p18,
              error_radius: 160,
              # e_g_i is test_box_1
              error_geographic_item: gi_b2)
            g.valid?
            expect(g.errors[:error_geographic_item]).to be_present
          end
      end
    end
  end

  context 'methods' do
    context '#error_box' do
      specify 'with error_radius returns a key-stone' do
        # case 2a - radius
        collecting_event_with_geographic_area.update!(verbatim_geolocation_uncertainty: '500m')
        georeference = Georeference::VerbatimData.new(
          collecting_event: collecting_event_with_geographic_area
        )

        # TODO: Figure out why the save of the georeference does not propagate down to the geographic_item
        # which is part of the geographic_area.
        #
        # here, we make sure the geographic_item gets saved.
        expect(collecting_event_with_geographic_area.geographic_area.default_geographic_item.save).to be_truthy
        georeference.save!
        # TODO: the following expectation will not be met, under some circumstances (different math packages on
        # different operating systems), and may have to be temporarily disabled

        # TODO: why did this shape change so much? Project change related?
        # old
        # a = 'POLYGON ((0.055084167377640034 0.14521842774992275 0.0, ' \
        #   '0.14491583262235996 0.14521842774992275 0.0, ' \
        #   '0.14491583262235996 0.054781572250077244 0.0, ' \
        #   '0.055084167377640034 0.054781572250077244 0.0, ' \
        #   '0.055084167377640034 0.14521842774992275 0.0))'

        # new
        a = 'POLYGON ((0.095508416737764 0.10452184277499228 0.0, 0.104491583262236 0.10452184277499228 0.0, 0.104491583262236 0.09547815722500773 0.0, 0.095508416737764 0.09547815722500773 0.0, 0.095508416737764 0.10452184277499228 0.0))'

        expect(georeference.error_box.to_s).to eq(a)
      end

      specify 'with error_geographic_item returns a shape' do
        # case 2a - error geo_item
        e_g_i.save!
        georeference = Georeference::VerbatimData.new(collecting_event:      collecting_event_with_geographic_area,
                                                      error_geographic_item: e_g_i)
        expect(georeference.save!).to be_truthy
        expect(georeference.error_box.geo_object.to_s).to eq(box_1.to_s)
      end
    end
    context 'batch_create_from_georeference_matcher' do
      specify 'adding this georeference to two collecting events' do
        georeference = Georeference::VerbatimData.new(collecting_event: collecting_event_with_geographic_area,
                                                      error_radius:     6000)
        georeference.save!
        ce1 = collecting_event_with_geographic_area
        ce2 = collecting_event_without_geographic_area
        ce2.save!
        arguments = {georeference_id: georeference.id.to_s, checked_ids: [ce1.id.to_s, ce2.id.to_s]}
        Georeference.batch_create_from_georeference_matcher(arguments)
        expect(ce1.georeferences.count).to eq(1)
        expect(ce2.georeferences.count).to eq(1)
        expect(Georeference.all.count).to eq(2)
      end
    end
  end

  context 'scopes' do
    # build some geo-references for testing using existing factories and geometries
    before(:each) {
      # gr1 = FactoryBot.create(:valid_georeference,
      #                           collecting_event: FactoryBot.create(:valid_collecting_event),
      #                           geographic_item:  FactoryBot.create(:geographic_item_with_polygon,
      #                                                               polygon: shape_k))
      # # swap out the polygon with another shape if needed
      #
      # @gr_poly  = FactoryBot.create(:valid_georeference_geo_locate)
      # @gr_point = FactoryBot.create(:valid_georeference_verbatim_data)
      #
      # # using linting to check validity of valid_ models! for things like
      # # gr1.save!
    }
    let(:gr1) { FactoryBot.create(:valid_georeference,
                                  collecting_event: FactoryBot.create(:valid_collecting_event),
                                  geographic_item:  FactoryBot.create(:geographic_item_with_polygon,
                                                                      polygon: shape_k)) }
    let(:gr_poly) { FactoryBot.create(:valid_georeference_geo_locate) }
    let(:gr_point) { FactoryBot.create(:valid_georeference_verbatim_data) }

    specify '.within_radius_of(geographic_item_id, distance)' do
      [gr_poly, gr_point, gr1].each
      expect(Georeference.within_radius_of_item(gr_point.geographic_item.to_param, 112000).to_a)
        .to contain_exactly(gr_poly, gr_point)      # but specifically *not* gr1
    end

    context '.with_locality_like(string)' do
      # return all Georeferences that are attached to a CollectingEvent that has a verbatim_locality that
      # includes String somewhere
      # Joins collecting_event.rb and matches %String% against verbatim_locality

      # .where(id in CollectingEvent.where{verbatim_locality like "%var%"})
      specify 'respondes to .with_locality_like' do
        expect(Georeference).to respond_to :with_locality_like
      end

      specify 'finds one' do
        expect(Georeference.with_locality_like('Illinois')).to contain_exactly(gr_point)
      end

      specify 'finds more than one' do
        expect(Georeference.with_locality_like('Locality '))
          .to contain_exactly(gr1.becomes(Georeference::VerbatimData), gr_poly)
      end

      specify 'finds none' do
        expect(Georeference.with_locality_like('Saskatoon')).to contain_exactly # nothing
      end
    end

    context '.with_locality(String)' do

      specify 'responds to .with_locality' do
        expect(Georeference).to respond_to :with_locality
      end

      specify 'finds one' do
        expect(Georeference.with_locality('Champaign Co., Illinois')).to contain_exactly(gr_point)
      end

      specify 'finds none' do
        expect(Georeference.with_locality('Saskatoon, Saskatchewan, Canada')).to contain_exactly() # nothing
      end
    end

    specify '.with_geographic_area(geographic_area)' do
      expect(Georeference).to respond_to :with_geographic_area

      p_a = earth

      g_a1 = GeographicArea.new(name:        'Box_1',
                                data_origin: 'Test Data',
                                #                       neID:                 'TD-001',
                                geographic_area_type:                         g_a_t,
                                parent:                                       p_a,
                                level0:                                       p_a,
                                geographic_areas_geographic_items_attributes: [{geographic_item: item_a,
                                                                                data_origin:     'Test Data'}])

      g_a2 = GeographicArea.new(name:        'Box_2',
                                data_origin: 'Test Data',
                                # gadmID:               2,
                                geographic_area_type:                         g_a_t,
                                parent:                                       p_a,
                                level0:                                       p_a,
                                geographic_areas_geographic_items_attributes: [{geographic_item: item_b,
                                                                                data_origin:     'Test Data'}])

      g_a3 = GeographicArea.new(name:        'Box_3',
                                data_origin: 'Test Data',
                                # tdwgID:               '12ABC',
                                geographic_area_type:                         g_a_t,
                                parent:                                       p_a,
                                level0:                                       p_a,
                                geographic_areas_geographic_items_attributes: [{geographic_item: item_c,
                                                                                data_origin:     'Test Data'}]
      )

      g_a4 = GeographicArea.new(name:                                         'Box_4',
                                data_origin:                                  'Test Data',
                                geographic_area_type:                         g_a_t,
                                parent:                                       p_a,
                                level0:                                       p_a,
                                geographic_areas_geographic_items_attributes: [{geographic_item: item_d,
                                                                                data_origin:     'Test Data'}])

      g_a4.save!

      # Create an orphan collecting_event which uses g_a4, so that first phase of 'with_geographic_area' will
      # have two records to find
      o_collecting_event = FactoryBot.create(:valid_collecting_event, geographic_area: g_a4)
      expect(o_collecting_event.valid?).to be_truthy

      # there are no georeferences which have collecting_events which have geographic_areas which refer to g_a1
      expect(Georeference.with_geographic_area(g_a4).to_a).to eq([])

      gr1.collecting_event.geographic_area = g_a4
      gr1.geographic_item                  = item_a
      gr1.collecting_event.save!
      gr1.save!

      expect(Georeference.with_geographic_area(g_a4).to_a).to eq([gr1.becomes(Georeference::VerbatimData)])
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end


