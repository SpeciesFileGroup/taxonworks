require 'spec_helper'

describe Georeference do

  #grgl = Georeference::GeoLocate.new()
  #grvd = Georeference::VerbatimData.new()

  let(:georeference) {FactoryGirl.build(:georeference)}
  let(:valid_georeference) {FactoryGirl.build(:valid_georeference)}
  let(:valid_georeference_geo_locate) {FactoryGirl.build(:valid_georeference_geo_locate)}
  let(:valid_georeference_verbatim_data) {FactoryGirl.build(:valid_georeference_verbatim_data)}

  let(:request_params) {
    {country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true'}
  }

  context 'validation' do
    before(:each) {
      georeference.save
    }

    specify '#geographic_item is required' do
      expect(georeference.errors.keys.include?(:geographic_item)).to be_true
    end
    specify '#collecting_event is required' do
      expect(georeference.errors.keys.include?(:collecting_event)).to be_true
    end
    specify '#type is required' do
      expect(georeference.errors.keys.include?(:type)).to be_true
    end
    specify "#error_geographic_item is required" do
      # <- what did we conclude if no error is provided, just nil? -> will cause issues if so for calculations
      pending 'setting error distance to 3 meters if not provided'
    end

    context 'legal values' do
    
      specify '#error_radius is < some Earth based limit' do
        # 12,000 miles
        pending 'setting error radius to some reasonable distance'
        #georeference.error_radius = 'some big radius'
        #expect(georeference.save).to be_false
        #expect(georeference.errors.keys.include?(:error_georeference)).to be_true

      end
      specify '#error_depth is < some Earth based limit' do
        # 10,000 meters
        pending 'setting error depth to some reasonable distance'
      end
      specify 'error_geographic_item.geo_object, when provided, should contain geographic_item.geo_object' do
        # case 1
        pending 'validation of the accceptability of the error geo_object, if provided'
      end
      specify 'collecting_event.geographic_area.geo_object contains self.geographic_item.geo_object or larger than georeference ?!' do
        pending 'determininization of what \'something like this\' means in the context of collecting_event'
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

    before(:each) {
      # build some geo-references for testing using existing factories and geometries, something roughly like this 
      @gr1 = FactoryGirl.build(:valid_georeference,
                               collecting_event: FactoryGirl.build(:valid_collecting_event, verbatim_locality: 'Some string'),
                               geographic_item: FactoryGirl.build(:geographic_item_with_polygon)) # swap out the polygon with another shape if needed

      # ...
      # @gr2
      # @gr3 
    }

    specify '.within_radius_of(geographic_item, distance)' do
      pending 'determinization of what is intended'
      # Return all Georeferences within some distance of a geographic_item
      # You're just going to use existing scopes in geographic item here, something like:
      # .where{geographic_item_id in GeographicItem.within_radius_of('polygon', geographic_item, distance)}
    end

    specify '.where_in_error_range_of(geographic_item, distance)' do
      pending 'adding #within_error_range of to georeference'
      # same as prior, but
      # .where{geographic_item_error_id: ... } 
    end

    specify '.with_locality_like(String)' do
      pending 'determinization of what is intended'
      # return all Georeferences that are attached to a CollectingEvent that has a verbatim_locality that includes String somewhere
      # Joins collecting_event.rb and matches %String% against verbatim_locality 

      # .where(id in CollectingEvent.where{verbatim_locality like "%var%"})
    end

    specify '.with_locality(String)' do
      pending 'determinization of what is intended'
      # return all Georeferences that are attached to a CollectingEvent that has a verbatim_locality = String
      # Joins collecting_event.rb and matches String against verbatim_locality,
      # .where(id in CollectingEvent.where{verbatim_locality = "var"})
    end

    specify '.with_geographic_area(geographic_area)' do
      pending 'determinization of what is intended'
      # where{geograhic_item_id: geographic_area.id}
    end
  end

  context 'request responses' do
    specify 'creates a geo_object' do
      #pending 'fixup on \'c\' vs. \'georeference\''
      c = Georeference::GeoLocate.new(request: request_params,
                                      collecting_event: FactoryGirl.build(:valid_collecting_event))
      c.locate
      c.save

      expect(c.geographic_item.class).to eq(GeographicItem)
      expect(c.geographic_item.geo_object.class).to eq(RGeo::Geographic::ProjectedPointImpl)
    end
=begin
      georeference.locate
      georeference.save!
      expect(georeference.geographic_item.class).to eq(GeographicItem)
      expect(georeference.geographic_item.geo_object.class).to eq(RGeo::Geographic::ProjectedPointImpl)
    end
=end

    specify 'can be geometrically compared through #geographic_item.geo_object' do
      c_locator = Georeference::GeoLocate.new(request: request_params,
                                              collecting_event: FactoryGirl.build(:valid_collecting_event))
      c_locator.locate
      u_locator = Georeference::GeoLocate.new(request: {country: 'USA', locality: 'Urbana', state: 'IL', doPoly: 'true'},
                                              collecting_event: FactoryGirl.build(:valid_collecting_event))

      c_locator.save
      u_locator.save

      expect(c_locator.error_geographic_item.geo_object.intersects?(u_locator.error_geographic_item.geo_object)).to be_true
      expect(c_locator.geographic_item.geo_object.distance(u_locator.geographic_item.geo_object)).to eq 0.03657760243645799
      expect(c_locator.geographic_item.geo_object.distance(u_locator.error_geographic_item.geo_object)).to eq 0.014470082533135583
      expect(u_locator.geographic_item.geo_object.distance(c_locator.error_geographic_item.geo_object)).to eq 0.021583346308561287
    end
  end


  context 'methods provide that' do
    context 'the object returns a type' do
      specify 'which is GeoLocate' do

        geo_locate = Georeference::GeoLocate.new(request: {country: 'USA', locality: 'Urbana', state: 'IL', doPoly: 'true'},
                                                 collecting_event: FactoryGirl.build(:valid_collecting_event))
        geo_locate.build
        geo_locate.save

        expect(geo_locate.type).to eq 'Georeference::GeoLocate'
      end

      specify 'which is Verbatim' do
        georeference = Georeference::VerbatimData.new(collecting_event: FactoryGirl.build(:valid_collecting_event,
                                                                                          minimum_elevation: 795,
                                                                                          verbatim_latitude: '40.092067',
                                                                                          verbatim_longitude: '-88.249519'))
        #georeference = FactoryGirl.build(:valid_georeference_verbatim_data)
        expect(georeference.type).to eq 'Georeference::VerbatimData'
      end
    end

  end
end


