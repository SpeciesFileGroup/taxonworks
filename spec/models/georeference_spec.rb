require 'rails_helper'

describe Georeference, :type => :model do

  after(:all) {
    GeographicItem.destroy_all
    Georeference.destroy_all
    CollectingEvent.destroy_all
    clean_slate_geo
  }

  #grgl = Georeference::GeoLocate.new()
  #grvd = Georeference::VerbatimData.new()

  let(:georeference) { FactoryGirl.build(:georeference) }
  let(:valid_georeference) { FactoryGirl.build(:valid_georeference) }
  let(:valid_georeference_geo_locate) { FactoryGirl.build(:valid_georeference_geo_locate) }
  let(:valid_georeference_verbatim_data) { FactoryGirl.build(:valid_georeference_verbatim_data) }

  let(:request_params) {
    {country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true'}
  }

  context 'validation' do
    before(:each) {
      georeference.save
    }

    specify '#geographic_item is required' do
      expect(georeference.errors.keys.include?(:geographic_item)).to be_truthy
    end
    specify '#collecting_event is required' do
      expect(georeference.errors.keys.include?(:collecting_event)).to be_truthy
    end
    specify '#type is required' do
      expect(georeference.errors.keys.include?(:type)).to be_truthy
    end
    specify "#error_geographic_item is not required" do
      # <- what did we conclude if no error is provided, just nil? -> will cause issues if so for calculations
      #skip 'setting error distance to 3 meters if not provided'
      expect(georeference.errors.keys.include?(:error_geographic_item)).to be_falsey
    end
    specify 'error_radius is not required' do
      expect(georeference.errors.keys.include?(:error_radius)).to be_falsey
    end
    specify 'error_depth is not required' do
      expect(georeference.errors.keys.include?(:error_depth)).to be_falsey
    end

    context 'legal values' do
      before(:each) {
        georeference.error_radius = 30000000
        georeference.error_depth  = 9000
        @e_g_i                    = GeographicItem.new(polygon: BOX_1)
        @item_d                   = GeographicItem.new(polygon: BOX_4)
        @g_a                      = GeographicArea.new(name:                 'Box_4',
                                                       data_origin:          'Test Data',
                                                       geographic_area_type: FactoryGirl.create(:testbox_geographic_area_type),
                                                       parent:               FactoryGirl.build(:earth_geographic_area))

        GeographicAreasGeographicItem.create(geographic_item: @item_d, geographic_area: @g_a)

        # this collecting event should produce a georeference.geographic_item.geo_object of 'Point(0.1 0.1 0.1)'
        @point0   = GeographicItem.new(point: POINT0)
        @point90n = GeographicItem.new(point: RSPEC_GEO_FACTORY.point(0, 90))
        @point45n = GeographicItem.new(point: RSPEC_GEO_FACTORY.point(0, 45))
        @c_e      = CollectingEvent.new(geographic_area:    @g_a,
                                        verbatim_locality:  'Test Event',
                                        minimum_elevation:  0.1,
                                        verbatim_latitude:  '0.1',
                                        verbatim_longitude: '0.1')

        @point0.save!
        @point90n.save!
        @point45n.save!
      }

      specify '#error_radius is < some Earth-based limit' do
        # 12,400 miles, 20,000 km
        #skip 'setting error radius to some reasonable distance'
        georeference.valid?
        expect(georeference.save).to be_falsey # many other reasons
        expect(georeference.errors.keys.include?(:error_radius)).to be_truthy

        georeference.error_radius = 3
        expect(georeference.save).to be_falsey # many other reasons
        expect(georeference.errors.keys.include?(:error_radius)).to be_falsey

      end

      specify '#error_depth is < some Earth-based limit' do
        # 8,800 meters
        #skip 'setting error depth to some reasonable distance'
        expect(georeference.save).to be_falsey # many other reasons
        expect(georeference.errors.keys.include?(:error_depth)).to be_truthy

        georeference.error_depth = 3
        expect(georeference.save).to be_falsey # many other reasons
        expect(georeference.errors.keys.include?(:error_depth)).to be_falsey

      end

      specify 'errors which result from badly formed error_geographic_item values' do
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_geographic_item: GeographicItem.new(polygon: POLY_E1))
        georeference.save
        expect(georeference.errors.keys.include?(:error_geographic_item)).to be_truthy
        expect(georeference.errors.keys.include?(:collecting_event)).to be_truthy

      end

      specify 'errors which result from badly formed error_radius values' do
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_radius:          16000,
                                                      error_geographic_item: @e_g_i)
        georeference.save
        expect(georeference.errors.keys.include?(:error_geographic_item)).to be_truthy
        expect(georeference.errors.keys.include?(:error_radius)).to be_truthy

      end

      specify 'errors which result from badly formed collecting_event area values and error_geographic_item' do
        # from the context 'before' process, item_d is already BOX_4
        # so we remove the old (outdated) association,
        @g_a.geographic_items.delete(@item_d)
        # create the new area,
        @item_d = GeographicItem.new(polygon: POLY_E1)
        # ()previous - @g_a.ne_geo_item = @item_d)
        # and create a new one to the new area
        GeographicAreasGeographicItem.create(geographic_area: @g_a, geographic_item: @item_d)
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      # @e_g_i is test_box_1
                                                      error_geographic_item: @e_g_i)

        expect(@c_e.geographic_area.default_geographic_item.save).to be_truthy

        georeference.valid?
        expect(georeference.errors.keys.include?(:error_geographic_item)).to be_truthy
        expect(georeference.errors.keys.include?(:geographic_item)).to be_truthy
        expect(georeference.errors.keys.include?(:collecting_event)).to be_truthy

      end

      specify 'errors which result from badly formed collecting_event area values and error_radius' do
        # from the context 'before' process, item_d is already BOX_4
        # so we remove the old (outdated) association,
        @g_a.geographic_items.delete(@item_d)

        @item_d = GeographicItem.new(polygon: POLY_E1)

        GeographicAreasGeographicItem.create(geographic_area: @g_a, geographic_item: @item_d)
        # @g_a.ne_geo_item = @item_d
        georeference = Georeference::VerbatimData.new(collecting_event: @c_e,
                                                      error_radius:     160000)
        expect(@c_e.geographic_area.default_geographic_item.save).to be_truthy
        georeference.save
        expect(georeference.errors.keys.include?(:error_radius)).to be_truthy
        expect(georeference.errors.keys.include?(:geographic_item)).to be_truthy
        expect(georeference.errors.keys.include?(:collecting_event)).to be_truthy

      end

      specify 'error_geographic_item.geo_object, when provided, should contain geographic_item.geo_object' do
        # case 1
        #   GeoRef    A (POINT0)
        #   GeoItem   B (BOX_B)
        #skip 'validation of the accceptability of the error geo_object, if provided'
        #
        # building up a georeference:
        #
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_geographic_item: @e_g_i)
        georeference.save
        expect(georeference.error_geographic_item.contains?(georeference.geographic_item.geo_object)).to be_truthy
      end

      specify '.error_box with error_radius returns a key-stone' do
        # case 2a - radius
        georeference = Georeference::VerbatimData.new(collecting_event: @c_e,
                                                      error_radius:     160000)
        # TODO: Figure out why the save of the georeference does not propagate down to the geographic_item which is part of the geographic_area.
        # here, we make sure the geographic_item gets saved.
        expect(@c_e.geographic_area.default_geographic_item.save).to be_truthy
        georeference.save
        # TODO: the following expectation will not be met, under some circumstances (different math packages on different operating systems), and has been temporarily disabled
        expect(georeference.error_box.to_s).to match(/POLYGON \(\(-1\.3445210431568\d* 1\.54698968799752\d* 0\.0, 1\.54452104315689\d* 1\.54698968799752\d* 0\.0, 1\.54452104315689\d* -1\.34698968799752\d* 0\.0, -1\.3445210431568\d* -1\.34698968799752\d* 0\.0, -1\.3445210431568\d* 1\.54698968799752\d* 0\.0\)\)/)
        #expect(georeference.error_box.to_s).to start_with 'POLYGON ((-1.34452104315689'
      end

      specify '.error_box with error_geographic_item returns a shape' do
        # case 2a - error geo_item
        @e_g_i.save
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_geographic_item: @e_g_i)
        expect(georeference.save).to be_truthy
        expect(georeference.error_box.geo_object.to_s).to eq(BOX_1.to_s)
      end

      specify 'error_radius, when provided, should contain geographic_item' do
        # case 2c
        # skip 'implementation of geo_object for geographic_area'
        # since the point specified is the center of a circle (or bounding box) defined by the error_radius, that point
        # must ALWAYS be 'contained' within the radius
        georeference = Georeference::VerbatimData.new(collecting_event: @c_e,
                                                      error_radius:     16000)
        expect(georeference.save).to be_truthy
        expect(georeference.error_box.contains?(georeference.geographic_item.geo_object)).to be_truthy
      end

      specify 'error_radius, when provided, should contain error_geographic_item, when provided' do
        # case 3
        georeference = Georeference::VerbatimData.new(collecting_event:      @c_e,
                                                      error_geographic_item: @e_g_i,
                                                      error_radius:          160000)
        georeference.save
        expect(georeference).to be_truthy
        expect(georeference.error_geographic_item.contains?(georeference.geographic_item.geo_object)).to be_truthy
        expect(georeference.error_geographic_item.contains?(georeference.geographic_item.geo_object)).to be_truthy
        # in this case, error_box returns bounding box of error_radius, and should contain the error_geographic_item
        expect(georeference.error_box.contains?(georeference.error_geographic_item.geo_object)).to be_truthy
      end

      specify 'collecting_event.geographic_area.geo_object contains self.geographic_item.geo_object or larger than georeference ?!' do
        # TODO: Don't know what 'or larger than georeference ?!' is supposed to mean
        #skip 'determination of what \'something like this\' means in the context of collecting_event'
        #   Need a GeographicArea somewhere on earth called
        # need a collecting event using box_1
        georeference = Georeference::VerbatimData.new(collecting_event: @c_e)
        expect(georeference.save).to be_truthy

        # @c_e got saved...
        expect(@c_e.new_record?).to be_falsey
        #
        # TODO: follow the save propagation chain and figure out why @c_e.@g_a.@item_d DID NOT get saved
        # expect(@c_e.geographic_area.default_geographic_item.new_record?).to be_truthy
        # force the save
        expect(@c_e.geographic_area.default_geographic_item.save).to be_truthy

        expect(georeference.collecting_event.geographic_area.geo_object.contains?(georeference.geographic_item.geo_object)).to be_truthy

      end
    end
  end


  context 'associations' do
    context 'belongs_to' do
      # Build a valid_georeference

      specify 'geographic_item' do
        expect(valid_georeference_geo_locate).to respond_to :geographic_item
        expect(valid_georeference_geo_locate.geographic_item.class).to eq(GeographicItem)
      end

      specify 'error_geographic_item' do
        expect(valid_georeference_geo_locate).to respond_to :error_geographic_item
      end

      specify 'collecting_event' do
        expect(valid_georeference_geo_locate).to respond_to :collecting_event
      end
    end

  end

  context 'scopes' do

    before(:all) { generate_geo_test_objects }

    before(:each) {
      # build some geo-references for testing using existing factories and geometries, something roughly like this
      #@center_point = FactoryGirl.build()
      @gr1 = FactoryGirl.create(:valid_georeference,
                                collecting_event: FactoryGirl.create(:valid_collecting_event),
                                geographic_item:  FactoryGirl.create(:geographic_item_with_polygon, polygon: SHAPE_K)) # swap out the polygon with another shape if needed

      @gr_poly = FactoryGirl.create(:valid_georeference_geo_locate)

      @gr_point = FactoryGirl.create(:valid_georeference_verbatim_data)

      @gr1.save!
      @gr_poly.save!
      @gr_point.save!

    }

    after(:all) { clean_slate_geo }

    specify '.within_radius_of(geographic_item, distance)' do
      #skip 'determination of what is intended'
      # Return all Georeferences within some distance of a geographic_item
      # You're just going to use existing scopes in geographic item here, something like:
      # .where{geographic_item_id in GeographicItem.within_radius_of('polygon', geographic_item, distance)}

      expect(Georeference).to respond_to :within_radius_of

      # TODOne: (04/15/14) these have to be turned into ActiveRecord::Relationship
      expect(Georeference.within_radius_of(@gr_point.geographic_item, 112000).to_a).to eq([@gr_poly, @gr_point])
      # but specifically *not* @gr1
      #skip 'construction of appropriate Georeference method'

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
      # skip 'construction of appropriate Georeference objects'

    end

    specify '.with_locality(String)' do
      # return all Georeferences that are attached to a CollectingEvent that has a verbatim_locality = String
      # Joins collecting_event.rb and matches String against verbatim_locality,
      # .where(id in CollectingEvent.where{verbatim_locality = "var"})
      expect(Georeference).to respond_to :with_locality
      # TODOne: (04/15/14) these have to be turned into ActiveRecord::Relationship
      expect(Georeference.with_locality('Champaign Co., Illinois').to_a).to eq([@gr_point])
      expect(Georeference.with_locality('Saskatoon, Saskatchewan, Canada').to_a).to eq([])
      # expect(Georeference.with_locality('Locality 8 for testing...').to_a).to eq([@gr1.becomes(Georeference::VerbatimData)])
      # skip 'construction of appropriate Georeference objects'

    end

    specify '.with_geographic_area(geographic_area)' do
      # where{geographic_item_id: geographic_area.id}
      expect(Georeference).to respond_to :with_geographic_area

      # build some special pieces

      p_a   = FactoryGirl.build(:earth_geographic_area)
      g_a_t = FactoryGirl.build(:testbox_geographic_area_type)

      @g_a1 = GeographicArea.new(name:                                         'Box_1',
                                 data_origin:                                  'Test Data',
                                 #                          neID:                 'TD-001',
                                 geographic_area_type:                         g_a_t,
                                 parent:                                       p_a,
                                 level0:                                       p_a,
                                 geographic_areas_geographic_items_attributes: [{geographic_item: @item_a, data_origin: 'Test Data'}])

      @g_a2 = GeographicArea.new(name:                                         'Box_2',
                                 data_origin:                                  'Test Data',
                                 # gadmID:               2,
                                 geographic_area_type:                         g_a_t,
                                 parent:                                       p_a,
                                 level0:                                       p_a,
                                 geographic_areas_geographic_items_attributes: [{geographic_item: @item_b, data_origin: 'Test Data'}])

      @g_a3 = GeographicArea.new(name:                                         'Box_3',
                                 data_origin:                                  'Test Data',
                                 # tdwgID:               '12ABC',
                                 geographic_area_type:                         g_a_t,
                                 parent:                                       p_a,
                                 level0:                                       p_a,
                                 geographic_areas_geographic_items_attributes: [{geographic_item: @item_c, data_origin: 'Test Data'}]
      )

      @g_a4 = GeographicArea.new(name:                                         'Box_4',
                                 data_origin:                                  'Test Data',
                                 geographic_area_type:                         g_a_t,
                                 parent:                                       p_a,
                                 level0:                                       p_a,
                                 geographic_areas_geographic_items_attributes: [{geographic_item: @item_d, data_origin: 'Test Data'}])

      @g_a4.save! # make sure the id is set

      # Create an orphan collecting_event which uses g_a4, so that first phase of 'with_geographic_area' will
      # have two records to find
      o_c_e = FactoryGirl.create(:valid_collecting_event, geographic_area: @g_a4)
      expect(o_c_e.valid?).to be_truthy

      # there are no georeferences which have collecting_events which have geographic_areas which refer to @g_a1
      expect(Georeference.with_geographic_area(@g_a4).to_a).to eq([])

      @gr1.collecting_event.geographic_area = @g_a4
      @gr1.geographic_item                  = @item_a
      @gr1.collecting_event.save!
      @gr1.save!

      expect(Georeference.with_geographic_area(@g_a4).to_a).to eq([@gr1.becomes(Georeference::VerbatimData)])
      # skip 'construction of appropriate Georeference objects'
    end
  end

end


