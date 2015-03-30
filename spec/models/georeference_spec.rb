require 'rails_helper'

describe Georeference, type: :model, group: :geo do
  let(:georeference) { FactoryGirl.build(:georeference) }

  let(:earth) { FactoryGirl.build(:earth_geographic_area) }
  let(:g_a_t) { FactoryGirl.build(:testbox_geographic_area_type) }

  let(:e_g_i) { GeographicItem.new(polygon: BOX_1) }
  let(:item_d) { GeographicItem.new(polygon: BOX_4) }

  let(:g_a) {
    GeographicArea.new(name:                 'Box_4',
                       data_origin:          'Test Data',
                       geographic_area_type: FactoryGirl.create(:testbox_geographic_area_type),
                       parent:               earth)
  }

  # this collecting event should produce a georeference.geographic_item.geo_object of 'Point(0.1 0.1 0.1)'
  let(:collecting_event_with_geographic_area) { CollectingEvent.new(geographic_area:    g_a,
                                                                    verbatim_locality:  'Test Event',
                                                                    minimum_elevation:  0.1,
                                                                    verbatim_latitude:  '0.1',
                                                                    verbatim_longitude: '0.1')
  }

  let(:collecting_event_without_geographic_area) {
    CollectingEvent.new(verbatim_locality: 'without geographic area')
  }


  let!(:gagi) { GeographicAreasGeographicItem.create(geographic_item: item_d, geographic_area: g_a) }


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

  context 'validation' do
    before(:each) {
      georeference.valid?
    }

    specify '#geographic_item is required' do
      expect(georeference.errors.include?(:geographic_item)).to be_truthy
    end

    specify '#collecting_event is required' do
      expect(georeference.errors.include?(:collecting_event)).to be_truthy
    end

    specify '#type is required' do
      expect(georeference.errors.include?(:type)).to be_truthy
    end

    specify "#error_geographic_item is not required" do
      expect(georeference.errors.include?(:error_geographic_item)).to be_falsey
    end

    specify '#error_radius is not required' do
      expect(georeference.errors.include?(:error_radius)).to be_falsey
    end

    specify 'error_depth is not required' do
      expect(georeference.errors.include?(:error_depth)).to be_falsey
    end

    context 'legal values' do
      specify '#error_radius is < some Earth-based limit' do
        # 12,400 miles, 20,000 km
        #skip 'setting error radius to some reasonable distance'
        georeference.error_radius = 30000000
        georeference.valid?
        expect(georeference.errors.keys.include?(:error_radius)).to be_truthy
      end

      specify '#error_radius can be set to something reasonable' do
        georeference.error_radius = 3
        georeference.valid?
        expect(georeference.errors.keys.include?(:error_radius)).to be_falsey
      end

      specify '#error_depth is < some Earth-based limit' do
        # 8,800 meters
        georeference.error_depth = 9000
        georeference.valid?
        expect(georeference.errors.keys.include?(:error_depth)).to be_truthy
      end

      specify '#error_depth can be set to something reasonable' do
        georeference.error_depth = 3
        georeference.valid?
        expect(georeference.errors.keys.include?(:error_depth)).to be_falsey
      end

      context 'allowed combinations of values' do
        before {
          georeference.type             = 'Georeference::GoogleMap'
          georeference.collecting_event = collecting_event_without_geographic_area
        }

        specify 'geographic_item without error_radius, error_depth, or error_geographic_item' do
          georeference.geographic_item = GeographicItem.new(point: SIMPLE_SHAPES[:point])
          expect(georeference.valid?).to be_truthy
        end

        specify 'geographic_item with error_radius' do
          georeference.geographic_item = GeographicItem.new(point: SIMPLE_SHAPES[:point])
          georeference.error_radius    = 10000
          expect(georeference.valid?).to be_truthy
        end

        specify 'geographic_item with error_geographic_item' do
          georeference.geographic_item = GeographicItem.new(point: 'POINT(5 5 0)')
          georeference.geographic_item = GeographicItem.new(polygon: 'POLYGON((0.0 0.0 0.0, 10.0 0.0 0.0, 10.0 10.0 0.0, 0.0 10.0 0.0, 0.0 0.0 0.0))')
          expect(georeference.valid?).to be_truthy
        end
      end
    end

    # ----------------------

    context 'geographic_item related' do
      # TODO: Remove.  The georeference should assume the geographic items handle their own error checking
      context 'malformed geographic_items' do

        specify 'errors which result from badly formed error_geographic_item values' do
          g = Georeference::VerbatimData.new(collecting_event:      collecting_event_with_geographic_area,
                                             error_geographic_item: GeographicItem.new(polygon: POLY_E1))
          g.valid?
          expect(g.errors.keys.include?(:error_geographic_item)).to be_truthy
          expect(g.errors.keys.include?(:collecting_event)).to be_truthy
        end

      end

      # TODO: what does this test?  We need to resolve the meaning of error_radius
      specify 'errors which result from badly formed error_radius values' do
        g = Georeference::VerbatimData.new(collecting_event:      collecting_event_with_geographic_area,
                                           error_radius:          16000,
                                           error_geographic_item: e_g_i)
        g.valid?
        expect(g.errors.keys.include?(:error_geographic_item)).to be_truthy
        expect(g.errors.keys.include?(:error_radius)).to be_truthy
      end

      context 'testing geographic_item/error against geographic area provided through collecting event' do
        let(:gi) { GeographicItem.create!(polygon: POLY_E1) }
        let(:ga) { GeographicArea.create!(name:                                         'foo area',
                                          data_origin:                                  'Test Data',
                                          geographic_area_type:                         g_a_t,
                                          parent:                                       earth,
                                          geographic_areas_geographic_items_attributes: [{geographic_item: gi, data_origin: 'Test Data'}]
        )
        }
        let(:ce) { CollectingEvent.new(geographic_area: ga) }

        before { GeographicAreasGeographicItem.create!(geographic_area: ga, geographic_item: gi) }

        # TODO: What does this mean?
        specify 'errors which result from badly formed collecting_event area values and error_geographic_item' do
          g = Georeference::VerbatimData.new(collecting_event:      ce,
                                             # e_g_i is test_box_1
                                             error_geographic_item: e_g_i)
          g.valid?

          expect(g.errors.keys.include?(:error_geographic_item)).to be_truthy
          expect(g.errors.keys.include?(:collecting_event)).to be_truthy
        end

        context 'an error is added to #geographic_item if collecting_event.geographic_area.geo_object does not contain #geographic_item' do
          pending ' '
        end

        context 'an error is added to #error_geographic_item if collecting_event.geographic_area.geo_object does not contain #error_geographic_item' do
          pending ' '
        end
      end

      pending 'an error is added to error_radius when error_radius provided and geographic_item not provided' # 2c
      pending 'an error is added to error_geographic_item when error_radius and point geographic_item do not fully contain error_geographic_item' # case 3

      #  specify 'error_radius, when provided, should contain geographic_item' do
      #    # case 2c
      #    # skip 'implementation of geo_object for geographic_area'
      #    # since the point specified is the center of a circle (or bounding box) defined by the error_radius, that point
      #    # must ALWAYS be 'contained' within the radius
      #    georeference = Georeference::VerbatimData.new(collecting_event: collecting_event_with_geographic_area,
      #                                                  error_radius:     16000)
      #    expect(georeference.save).to be_truthy
      #    expect(georeference.error_box.contains?(georeference.geographic_item.geo_object)).to be_truthy
      #  end

      #     specify 'error_radius, when provided with geographic_item, should contain error_geographic_item, when provided' do
      #       # case 3
      #       georeference = Georeference::VerbatimData.new(collecting_event:      collecting_event_with_geographic_area,
      #                                                     error_geographic_item: e_g_i,
      #                                                     error_radius:          160000)
      #       georeference.save
      #       expect(georeference).to be_truthy
      #       expect(georeference.error_geographic_item.contains?(georeference.geographic_item.geo_object)).to be_truthy
      #       expect(georeference.error_geographic_item.contains?(georeference.geographic_item.geo_object)).to be_truthy
      #       # in this case, error_box returns bounding box of error_radius, and should contain the error_geographic_item
      #       expect(georeference.error_box.contains?(georeference.error_geographic_item.geo_object)).to be_truthy
      #     end

    end
  end

  context 'methods' do
    context '#error_box' do
      specify 'with error_radius returns a key-stone' do
        # case 2a - radius
        georeference = Georeference::VerbatimData.new(collecting_event: collecting_event_with_geographic_area,
                                                      error_radius:     160000)
        # TODO: Figure out why the save of the georeference does not propagate down to the geographic_item which is part of the geographic_area.
        # here, we make sure the geographic_item gets saved.
        expect(collecting_event_with_geographic_area.geographic_area.default_geographic_item.save).to be_truthy
        georeference.save
        # TODO: the following expectation will not be met, under some circumstances (different math packages on different operating systems), and has been temporarily disabled
        expect(georeference.error_box.to_s).to match(/POLYGON \(\(-1\.3445210431568\d* 1\.54698968799752\d* 0\.0, 1\.54452104315689\d* 1\.54698968799752\d* 0\.0, 1\.54452104315689\d* -1\.34698968799752\d* 0\.0, -1\.3445210431568\d* -1\.34698968799752\d* 0\.0, -1\.3445210431568\d* 1\.54698968799752\d* 0\.0\)\)/)
        #expect(georeference.error_box.to_s).to start_with 'POLYGON ((-1.34452104315689'
      end

      specify 'with error_geographic_item returns a shape' do
        # case 2a - error geo_item
        e_g_i.save
        georeference = Georeference::VerbatimData.new(collecting_event:      collecting_event_with_geographic_area,
                                                      error_geographic_item: e_g_i)
        expect(georeference.save).to be_truthy
        expect(georeference.error_box.geo_object.to_s).to eq(BOX_1.to_s)
      end
    end
  end


  context 'scopes' do
    before(:all) {
      generate_geo_test_objects
    }

    after(:all) {
      clean_slate_geo
    }

    # build some geo-references for testing using existing factories and geometries
    before(:each) {
      @gr1 = FactoryGirl.create(:valid_georeference,
                                collecting_event: FactoryGirl.create(:valid_collecting_event),
                                geographic_item:  FactoryGirl.create(:geographic_item_with_polygon, polygon: SHAPE_K)) # swap out the polygon with another shape if needed

      @gr_poly  = FactoryGirl.create(:valid_georeference_geo_locate)
      @gr_point = FactoryGirl.create(:valid_georeference_verbatim_data)

      # using linting to check validity of valid_ models! for things like 
      # @gr1.save!
    }

    specify '.within_radius_of(geographic_item, distance)' do
      expect(Georeference).to respond_to :within_radius_of
      expect(Georeference.within_radius_of(@gr_point.geographic_item, 112000).to_a).to eq([@gr_poly, @gr_point])
      # but specifically *not* @gr1
    end

    specify '.with_locality_like(string)' do
      # return all Georeferences that are attached to a CollectingEvent that has a verbatim_locality that includes String somewhere
      # Joins collecting_event.rb and matches %String% against verbatim_locality 

      # .where(id in CollectingEvent.where{verbatim_locality like "%var%"})
      expect(Georeference).to respond_to :with_locality_like
      # TODO: (04/15/14) these have to be turned into ActiveRecord::Relationship
      expect(Georeference.with_locality_like('Illinois').to_a).to eq([@gr_point])
      expect(Georeference.with_locality_like('Locality ').to_a).to eq([@gr1.becomes(Georeference::VerbatimData), @gr_poly])
      expect(Georeference.with_locality_like('Saskatoon').to_a).to eq([])
    end

    specify '.with_locality(String)' do
      expect(Georeference).to respond_to :with_locality
      expect(Georeference.with_locality('Champaign Co., Illinois').to_a).to eq([@gr_point])
      expect(Georeference.with_locality('Saskatoon, Saskatchewan, Canada').to_a).to eq([])
      # expect(Georeference.with_locality('Locality 8 for testing...').to_a).to eq([@gr1.becomes(Georeference::VerbatimData)])
    end

    specify '.with_geographic_area(geographic_area)' do
      expect(Georeference).to respond_to :with_geographic_area

      p_a = earth

      g_a1 = GeographicArea.new(name:                                         'Box_1',
                                data_origin:                                  'Test Data',
                                #                       neID:                 'TD-001',
                                geographic_area_type:                         g_a_t,
                                parent:                                       p_a,
                                level0:                                       p_a,
                                geographic_areas_geographic_items_attributes: [{geographic_item: @item_a, data_origin: 'Test Data'}])

      g_a2 = GeographicArea.new(name:                                         'Box_2',
                                data_origin:                                  'Test Data',
                                # gadmID:               2,
                                geographic_area_type:                         g_a_t,
                                parent:                                       p_a,
                                level0:                                       p_a,
                                geographic_areas_geographic_items_attributes: [{geographic_item: @item_b, data_origin: 'Test Data'}])

      g_a3 = GeographicArea.new(name:                                         'Box_3',
                                data_origin:                                  'Test Data',
                                # tdwgID:               '12ABC',
                                geographic_area_type:                         g_a_t,
                                parent:                                       p_a,
                                level0:                                       p_a,
                                geographic_areas_geographic_items_attributes: [{geographic_item: @item_c, data_origin: 'Test Data'}]
      )

      g_a4 = GeographicArea.new(name:                                         'Box_4',
                                data_origin:                                  'Test Data',
                                geographic_area_type:                         g_a_t,
                                parent:                                       p_a,
                                level0:                                       p_a,
                                geographic_areas_geographic_items_attributes: [{geographic_item: item_d, data_origin: 'Test Data'}])

      g_a4.save!

      # Create an orphan collecting_event which uses g_a4, so that first phase of 'with_geographic_area' will
      # have two records to find
      o_collecting_event = FactoryGirl.create(:valid_collecting_event, geographic_area: g_a4)
      expect(o_collecting_event.valid?).to be_truthy

      # there are no georeferences which have collecting_events which have geographic_areas which refer to g_a1
      expect(Georeference.with_geographic_area(g_a4).to_a).to eq([])

      @gr1.collecting_event.geographic_area = g_a4
      @gr1.geographic_item                  = @item_a
      @gr1.collecting_event.save!
      @gr1.save!

      expect(Georeference.with_geographic_area(g_a4).to_a).to eq([@gr1.becomes(Georeference::VerbatimData)])
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end


