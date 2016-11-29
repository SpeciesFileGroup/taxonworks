require 'rails_helper'

describe CollectingEvent, type: :model, group: [:geo, :collecting_event] do
  let(:collecting_event) { CollectingEvent.new }
  let(:county) { FactoryGirl.create(:valid_geographic_area_stack) }
  let(:state) { county.parent }
  let(:country) { state.parent }

  context 'with political areas and collecting events generated' do
    before(:all) { generate_political_areas_with_collecting_events }
    after(:all) { clean_slate_geo }

    context 'geographic names' do
      before{collecting_event.save!}

      context '#geographic_name_classification' do
        specify 'with no data #geographic_name_classification returns nil' do
          expect(collecting_event.geographic_name_classification_method).to eq(nil)
        end

        context 'with a georeference set ' do
          before{collecting_event.georeferences << FactoryGirl.create(:valid_georeference)}

          specify '#geographic_name_classification returns :preferred_georeference' do
            expect(collecting_event.geographic_name_classification_method).to eq(:preferred_georeference)
          end
        end

        context 'with a geographic area that has a shape set ' do
          before do
            country.geographic_items << FactoryGirl.create(:geographic_item_with_polygon)
            collecting_event.update_column(:geographic_area_id, country.id)
          end

          specify '#geographic_name_classification returns :geographic_area_with_shape' do
            expect(collecting_event.geographic_name_classification_method).to eq(:geographic_area_with_shape)
          end
        end

        context 'with #geographic_area (no shape) set' do
          before{collecting_event.update_column(:geographic_area_id, state.id)}

          specify '#geographic_name_classification returns :geographic_area' do
            expect(collecting_event.geographic_name_classification_method).to eq(:geographic_area)
          end
        end
      end

      context 'caching' do
        context 'with no data' do
          specify '#cached_geographic_name_classification returns {}' do
            expect(collecting_event.cached_geographic_name_classification).to eq({})
          end
        end

        context 'with a verbatim georeference' do
          before do
            collecting_event.update_attributes(
              verbatim_latitude: '27.5',
              verbatim_longitude: '33.5'
            )
            Georeference::VerbatimData.create!(collecting_event: collecting_event)
          end

          specify 'country, state, county are cached on creation of georefernce' do
            expect(collecting_event.cached_geographic_name_classification).to eq( {:country=>"West Boxia", :state=>"QT", :county=>"M1"} )
          end
        end

        context 'after #geographic_name_classification has been called, cached values are set' do
          context 'with a geographic_area (no shape) set to country (level0)' do
            before do
              collecting_event.update_column(:geographic_area_id, country.id)
              collecting_event.geographic_name_classification
            end

            specify '#cached_geographic_name_classification returns { country: country_name }' do
              expect(collecting_event.cached_geographic_name_classification).to eq( {country: country.name} )
            end
          end

          context 'with a geographic_area (no shape) set to state (level1)' do
            before do
              collecting_event.update_column(:geographic_area_id, state.id)
              collecting_event.geographic_name_classification
            end

            specify '#cached_geographic_name_classification returns { country: country_name, state: state_name }' do
              expect(collecting_event.cached_geographic_name_classification).to eq({country: country.name, state: state.name })
            end
          end

          context 'with a geographic_area (no shape) set to county (level2)' do
            before do
              collecting_event.update_column(:geographic_area_id, county.id)
              collecting_event.geographic_name_classification
            end

            specify '#cached_geographic_name_classification returns { country: country_name, state: state_name, county: county_name }' do
              expect(collecting_event.cached_geographic_name_classification).to eq({country: country.name, state: state.name, county: county.name})
            end
          end

          context 'cached values are updated after geographic_area_id is updated' do
            before do
              collecting_event.update_column(:geographic_area_id, county.id)
              collecting_event.geographic_name_classification
              collecting_event.update_attribute(:geographic_area_id, state.id)
            end

            specify '#cached_geographic_name_classification returns { country: country_name, state: state_name }' do
              expect(collecting_event.cached_geographic_name_classification).to eq({country: country.name, state: state.name })
            end
          end

          context 'cached values are NOT updated when no_cache: true' do
            before do
              collecting_event.no_cached = true
              collecting_event.update_attribute(:geographic_area_id, county.id)
            end

            specify '#cached_geographic_name_classification returns {  }' do
              expect(collecting_event.cached_geographic_name_classification).to eq({ })
            end
          end
        end
      end
    end

    # -----

    context 'returning the most refined latitude and longitude' do
      context 'when no possible lat long provided' do
        specify '#map_center_method' do
          expect(collecting_event.map_center_method).to eq(nil)
        end

        specify '#map_center' do
          expect(collecting_event.map_center).to eq(nil)
        end

        context 'geographic_area_provided' do
          before {
            collecting_event.geographic_area = @area_m1
          }

          specify '#map_center_method' do
            expect(collecting_event.map_center_method).to eq(:geographic_area)
          end

          specify 'return geographic area centroid' do
            expect(collecting_event.map_center).to eq(@area_m1.default_geographic_item.geo_object.centroid) # check to see if geo_object has native centroid method
          end

          context 'verbatim_map_center provided' do
            before {
              collecting_event.verbatim_latitude = '1.0'
              collecting_event.verbatim_longitude = '2.0'
            }

            specify '#map_center_method' do
              expect(collecting_event.map_center_method).to eq(:verbatim_map_center)
            end

            specify 'return verbatim_map_center' do
              expect(collecting_event.map_center).to eq(collecting_event.verbatim_map_center) # Gis::FACTORY.point('2.0', '1.0')
            end

            context 'georeference provided' do
              before {
                collecting_event.save

                FactoryGirl.create(:georeference_verbatim_data,
                                   collecting_event: collecting_event,
                                   geographic_item: GeographicItem.new(point: @item_m1.geo_object.centroid))
                collecting_event.reload
              }

              specify '#map_center_method' do
                expect(collecting_event.map_center_method).to eq(:preferred_georeference)
              end

              specify 'return georeference#geographic_item centroid' do
                expect(collecting_event.map_center).to eq(@item_m1.geo_object.centroid   )
              end
            end
          end
        end

      end
    end
  end

  context '#verbatim_map_center' do
    specify 'when verbatim_latitude and verbatim_longitude not provided' do
      expect(collecting_event.verbatim_map_center).to eq(nil)
    end

    specify 'when verbatim_latitude and verbatim_longitude provided, returns a Rgeo object' do
      collecting_event.verbatim_latitude = '1.0'
      collecting_event.verbatim_longitude = '2.0'
      expect(collecting_event.verbatim_map_center).to eq( Gis::FACTORY.point('2.0', '1.0') )
    end
  end


  context 'georeferences' do

    # Jim- querying across multiple columns (polygon, multi-polygon etc.) is going to be tricky,
    # we will likely need to write some sql generators to do this efficiently.  To start
    # you could just pick one column, and we can abstract out the problem later.
    context 'when the CE has a GR' do
      before(:all) {
        generate_ce_test_objects(1, 1)
      }

      context 'and that GR has some combination of GIs, and EGIs' do
        specify 'that the count of which can be found' do
          # pending 'fixing the bug in all_geographic_items' # todo: @mjy
          # @ce_p5 has two GRs, each of which has a GI.
          results = @ce_p5.all_geographic_items
          expect(results.count).to eq(2)
          expect(results).to include(@p15, @p5)
          # @ce_p8 has two GRs, one of which has only a GI, and the other of which
          # has a GI, and an EGI.
          results = @ce_p8.all_geographic_items
          expect(results.count).to eq(3)
          expect(results.to_a).to include(@p18, @p8, @b2)
          # #ce_area_v has no GR.
          results = @ce_area_v.all_geographic_items
          expect(results.count).to eq(0)
        end
      end

      context 'and that GR has a GI but no EGI' do
        specify 'find other CEs that have GRs whose GI or EGI is within some radius of the source GI' do
          pieces = @ce_p7.collecting_events_within_radius_of(2000000)
          expect(pieces.count).to eq(6)
          expect(pieces).to include(@ce_p0, # @ce_p2, @ce_p3,
                                    @ce_p5, @ce_p6, @ce_p8, @ce_p9)
          expect(pieces).not_to include(@ce_p1, @ce_p4, @ce_p7)
        end

        specify 'find other CEs that have GRs whose GI or EGI intersects the source GI' do
          pieces = @ce_p2.collecting_events_intersecting_with
          # @ce_p2.first will find @k and @p2
          # @k will find @p1, @p2, @p3, filter out @p2, and return @p1 and @p3
          expect(pieces.count).to eq(2)
          expect(pieces).to include(@ce_p1, @ce_p3)
          expect(pieces).not_to include(@ce_p7) # even though @p17 is close to @k
        end
      end

      context 'and that GR has both GI and EGI' do
        # was: 'find other CEs that have GR whose GIs or EGIs are within some radius of the EGI'
        specify 'find other CEs that have GR whose GIs are within some radius' do
          pieces = @ce_p2.collecting_events_within_radius_of(1000000)
          expect(pieces.count).to eq(4)
          expect(pieces).to include(@ce_p1, @ce_p3,
                                    @ce_p4, @ce_p7)
          # @ce_p1 is included because of @p1,
          # @ce_p3 is included because of @p3,
          # @ce_p4 is included because of @p4,
          # @ce_p7 is included because of @p17 (near @k)
          expect(pieces).not_to include(@ce_p0)
        end

        specify 'find other CEs that have GRs whose GIs or EGIs are contained in the EGI' do
          # skip 'contained in error_gi'
          pieces = @ce_p1.collecting_events_contained_in_error
          expect(pieces.count).to eq(1)
          expect(pieces.first).to eq(@ce_p2)
          expect(pieces).not_to include(@ce_p1)
        end
      end


      context 'geolocate responses from collecting_event' do
        before(:all) {
          generate_political_areas_with_collecting_events
        }

        after(:all) {
          clean_slate_geo
        }

        context 'geolocate_ui_params' do
          specify 'geolocate_ui_params from locality' do
            # @ce_n3 was built with locality, with no verbatim_lat/long
            expect(@ce_n3.geolocate_ui_params).to eq({'country'       => 'Old Boxia',
                                                      'state'         => 'N3',
                                                      'county'        => nil,
                                                      'locality'      => 'Greater Boxia Lake',
                                                      'Latitude'      => 25.5,
                                                      'Longitude'     => 34.5,
                                                      'Placename'     => 'Greater Boxia Lake',
                                                      'Score'         => '0',
                                                      'Uncertainty'   => '3',
                                                      'H20'           => 'false',
                                                      'HwyX'          => 'false',
                                                      'Uncert'        => 'true',
                                                      'Poly'          => 'true',
                                                      'DisplacePoly'  => 'false',
                                                      'RestrictAdmin' => 'false',
                                                      'BG'            => 'false',
                                                      'LanguageIndex' => '0',
                                                      'gc'            => 'Tester'
            })
          end

          specify 'geolocate_ui_params from lat/long' do
            # @ce_m1.georeference was built from verbatim data; no locality
            expect(@ce_m1.geolocate_ui_params).to eq({'country'       => 'Big Boxia',
                                                      'state'        => 'QT',
                                                      'county'        => 'M1',
                                                      'locality'      => 'Lesser Boxia Lake',
                                                      'Latitude'      => 27.5,
                                                      'Longitude'     => 33.5,
                                                      'Placename'     => 'Lesser Boxia Lake',
                                                      'Score'         => '0',
                                                      'Uncertainty'   => '3',
                                                      'H20'           => 'false',
                                                      'HwyX'          => 'false',
                                                      'Uncert'        => 'true',
                                                      'Poly'          => 'true',
                                                      'DisplacePoly'  => 'false',
                                                      'RestrictAdmin' => 'false',
                                                      'BG'            => 'false',
                                                      'LanguageIndex' => '0',
                                                      'gc'            => 'Tester'
            })
          end
        end

        context 'geolocate_ui_params_string' do

          specify 'geolocate_ui_params_string from locality' do
            #pending 'creation of a method for geolocate_ui_params_string'
            expect(@ce_n3.geolocate_ui_params_string).to eq('http://www.museum.tulane.edu/geolocate/web/webgeoreflight.aspx?country=Old Boxia&state=N3&county=&locality=Greater Boxia Lake&points=25.5|34.5|Greater Boxia Lake|0|3&georef=run|false|false|true|true|false|false|false|0&gc=Tester')
          end

          specify 'geolocate_ui_params_string from lat/long' do
            #pending 'creation of a method for geolocate_ui_params_string'
            expect(@ce_m1.geolocate_ui_params_string).to eq('http://www.museum.tulane.edu/geolocate/web/webgeoreflight.aspx?country=Big Boxia&state=QT&county=M1&locality=Lesser Boxia Lake&points=27.5|33.5|Lesser Boxia Lake|0|3&georef=run|false|false|true|true|false|false|false|0&gc=Tester')
          end
        end
      end

    end

  end


end


context 'creating a collecting event with no resolvable geographic_name_classification' do
  let(:earth) { FactoryGirl.create(:earth_geographic_area) }

  specify 'suceeds without entering a nasty loop' do
    expect(CollectingEvent.create(geographic_area: earth) ).to be_truthy
    expect(CollectingEvent.last.geographic_name_classification).to eq({})
  end
end


context 'georeferences' do
  context 'verbatim georeferences using with_verbatim_data_georeference: true' do

    context 'on new()' do
      specify 'creates a verbatim georeference using new()' do
        c = CollectingEvent.new(verbatim_latitude: '10.001', verbatim_longitude: '10', project: @project, with_verbatim_data_georeference: true)
        expect(c.save!).to be_truthy
        expect(c.verbatim_data_georeference.id).to be_truthy
      end
    end

    context 'on create()' do
      let(:c) { CollectingEvent.create!(verbatim_latitude: '10.001', verbatim_longitude: '10', project: @project, with_verbatim_data_georeference: true) }

      specify '#verbatim_data_georeference.id is set' do
        expect(c.verbatim_data_georeference.id).to be_truthy
      end

      specify '#verbatim_data_georeference.geographic_item.id is set' do
        expect(c.verbatim_data_georeference.geographic_item.id).to be_truthy
      end

      specify '#verbatim_data_georeference.project_id is set' do
        expect(c.verbatim_data_georeference.project_id).to be_truthy
      end
    end

    specify 'creates a geo object that acurately represents the verbatim values' do
      c = CollectingEvent.create(verbatim_latitude: '10.001', verbatim_longitude: '10', project: @project, with_verbatim_data_georeference: true)
      # ! do points have to be decimalized?
      expect(c.verbatim_data_georeference.geographic_item.geo_object.to_s).to eq('POINT (10.0 10.001 0.0)')
    end

    context "using by cascades creator/updater to georeference and geographic_item" do
      let(:other_user) { FactoryGirl.create(:valid_user, name: 'other', email: 'other@test.com') }
      let(:c) { CollectingEvent.create(verbatim_latitude: '10.001', verbatim_longitude: '10', project: @project, with_verbatim_data_georeference: true, by: other_user) }

      specify 'sets collecting event updater' do
        expect(c.updater).to eq(other_user)
      end

      specify 'sets collecting event creator' do
        expect(c.updater).to eq(other_user)
      end

      specify 'sets verbatim_data_georeference updater' do
        expect(c.verbatim_data_georeference.updater).to eq(other_user)
      end

      specify 'sets verbatim_data_georeference creator' do
        expect(c.verbatim_data_georeference.creator).to eq(other_user)
      end

      specify 'sets verbatim_data_georeference.geographic_item updater' do
        expect(c.verbatim_data_georeference.geographic_item.updater).to eq(other_user)
      end

      specify 'sets verbatim_data_georeference.geographic_item creator' do
        expect(c.verbatim_data_georeference.geographic_item.creator).to eq(other_user)
      end
    end
  end
end

context 'geopolitical labels' do

  # this context is here 2x, see if we can simlify it
  before(:all) {
    # create some bogus countries, states, provinces, counties, and a parish
    generate_political_areas_with_collecting_events
    #
    # The idea:
    #    - geopolitical names all come from GeographicArea, as classified by GeographicAreaType
    #    - we can arrive at a geographic_area from a collecting event in 2 ways
    #       1) @collecting_event.geographic_area is set, this is easy, we can use it specifically
    #          if it's the right type, or climb up to a specific levelN category to check if not
    #       2) @collecting_event.georeferences.first is set.
    #          In the case of 2) we must use the georeference to find the minimum containing geographic_area
    #          of type "state" for example
    #   - it is possible (but hopefully unlikely) that multiple geographic areas of type "state" might be return,
    #
    # We want to derive labels in two stages
    #     1) a hash stage finds all possible values, where keys are a string, and values are an array, e.g.
    #         'Canada' => [@geographic_area1, @geographic_area2]
    #     2) a name stage use the hash from 1) to pick the "best" label (see priorities in tests)
    #
  }

  after(:all) {
    clean_slate_geo
  }

  context 'countries' do
    context 'should return hash of the country with #countries_hash' do
      context 'when one possible name is present' do
        specify 'derived from geographic_area_chain' do
          # @ce_o3 has no georeference, so the only way to 'S' is through geographic_area
          list = @ce_o3.countries_hash
          expect(list).to include({'S' => [@area_s]})
          expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
        end
        specify 'derived from georeference -> geographic_areas chain' do
          # @ce_p4 has no geographic_area, so the only way to 'S' is through georeference
          list = @ce_p4.countries_hash
          expect(list).to include({'S' => [@area_s]})
          expect(list).to include({'East Boxia' => [@area_east_boxia_1]})
          expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
        end
      end

      context 'when more than one possible name is present' do
        specify 'derived from geographic_area_chain' do
          # 'Q' is synonymous with 'Big Boxia'
          # @ce_n1 has no georeference, so the only way to 'Q' is through geographic_area
          list = @ce_n1.countries_hash
          expect(list).to include({'Q' => [@area_q]})
          expect(list).to include({'Old Boxia' => [@area_old_boxia]})
          expect(list).to include({'Big Boxia' => [@area_big_boxia]})
          #  'Great Northern Land Mass' contains 'Q', and thus m1, but is NOT type 'Country'
          expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
        end
        specify 'derived from georeference -> geographic_areas chain' do
          # @ce_p1 has both geographic_area and georeference; georeference has priority
          list = @ce_p1.countries_hash
          expect(list).to include({'Q' => [@area_q]})
          expect(list).to include({'Big Boxia' => [@area_big_boxia]})
          expect(list.keys).to include('East Boxia')
          expect(list['East Boxia']).to include(@area_east_boxia_1, @area_east_boxia_2)
          #  'Great Northern Land Mass' contains 'Q', and thus p1, but is NOT type 'Country'
          expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
        end
      end
    end

    context '#country_name' do
      context 'derivation priority' do
        specify 'it should return nil when no georeference or CollectingEvent#geographic_area_id is present' do
          # @ce_v is the right CE for this test.
          expect(@ce_v.country_name).to be_nil
        end
        specify 'it should return the value derived from the georeference "chain" if both present' do
          # @ce_o1 has a GR, and a GA, and leads to 'Big Boxia', 'East Boxia', and 'Q'
          expect(@ce_o1.country_name).to eq('Big Boxia') # 'Big Boxia' is alphabetically first
        end
        specify 'it should return the value derived from the geographic_area chain if georeference chain is not present' do
          # @ce_o3 has no GR.
          expect(@ce_o3.country_name).to eq('S')
        end
      end

      context 'result priority' do
        specify 'it should return #countries_hash.keys.first when only one key is present' do
          # @ce_o3 leads to only one GA (named area).
          expect(@ce_o3.country_name).to eq('S')
        end
        specify 'it should return the #countries_hash.key that has the most #countries_hash.values if more than one present' do
          # @ce_n2 leads back to three GAs; 'Q', 'Big Boxia', and 'Old Boxia'
          expect(@ce_n2.country_name).to eq('Big Boxia') # alphabetic ordering
          # @ce_p1 leads to 'Q', 'Big Boxia', and 'East Boxia', which has two areas. This fact causes
          #   'East Boxia' to be selected over the alphabetically first 'Big Boxia'
          expect(@ce_p1.country_name).to eq('East Boxia')
        end
        specify 'it should return the first #countries_hash.key when an equal number of .values is present' do
          # @ce_n3 leads back to two GAs; 'R', and 'Old Boxia'
          expect(@ce_n3.country_name).to eq('Old Boxia') # alphabetic ordering
        end
      end
    end
  end

  context 'states' do
    context 'should return hash of the state with #states_hash' do
      context 'when one possible name is present' do
        specify 'derived from geographic_area_chain' do
          # @ce_o3 has no georeference, so the only way to 'O3' is through geographic_area
          expect(@ce_o3.states_hash).to include({'O3' => [@area_o3]}, {'SO3' => [@area_so3]})
          # @ce_p2 has no georeference, so the only way to 'U' is through geographic_area
          expect(@ce_p2.states_hash).to include({'QU' => [@area_u]}, {'East Boxia' => [@area_east_boxia_3]})
        end
        specify 'derived from georeference -> geographic_areas chain' do
          # @ce_n4 has no geographic_area, so the only way to 'N4' is through georeference
          expect(@ce_n4.states_hash).to include({'N4' => [@area_n4]}, {'RN4' => [@area_rn4]})
          # @ce_n4 has no geographic_area, so the only way to 'T' is through georeference
          list = @ce_n2.states_hash
          expect(list.keys).to include('QT')
          expect(list['QT']).to include(@area_t_1, @area_t_2)
        end
      end

      context 'when more than one possible name is present' do
        specify 'derived from geographic_area_chain' do
          # 'T' is a state in 'Q'
          list = @ce_m1.states_hash
          expect(list.keys).to include('QT')
          expect(list['QT']).to include(@area_t_1, @area_t_2)
        end
        specify 'derived from georeference -> geographic_areas chain' do
          # @ce_p1 has both geographic_area and georeference; georeference has priority
          list = @ce_p1.states_hash
          expect(list.keys).to include('QU', 'East Boxia')
        end
      end
    end

    context '#state_name' do
      context 'derivation priority' do
        specify 'it should return nil when no georeference or CollectingEvent#geographic_area_id is present' do
          # @ce_v is the right CE for this test.
          expect(@ce_v.state_name).to be_nil
        end
        specify 'it should return the value derived from the georeference "chain" if both present' do
          # @ce_p1 has a GR, and a GA. 'East Boxia' and 'U' will be the found names
          expect(@ce_p1.state_name).to eq('East Boxia') # 'East Boxia' is alphabetically first.
        end
        specify 'it should return the value derived from the geographic_area chain if georeference chain is not present' do
          # @ce_o3 has no GR.
          expect(@ce_o3.state_name).to eq('O3')
        end
      end

      context 'result priority' do
        specify 'it should return #states_hash.keys.first when only one key is present' do
          # @ce_o3 leads to only one GA (named area).
          expect(@ce_o3.state_name).to eq('O3')
        end
        specify 'it should return the #states_hash.key that has the most #countries_hash.values if more than one present' do
          # @ce_n2 leads back to three GAs; 'Q', 'Big Boxia', and 'Old Boxia'
          expect(@ce_n2.state_name).to eq('QT')
        end
        specify 'it should return the first #states_hash.key when an equal number of .values is present' do
          # @ce_n3 is state names 'N3', and leads back to two GAs; 'R', and 'Old Boxia'
          expect(@ce_n3.state_name).to eq('N3')
        end
      end
    end
  end

  context 'counties' do
    context 'should return hash of the county with #counties_hash' do
      context 'when one possible name is present' do
        specify 'derived from geographic_area_chain' do
          # @ce_p2 has no georeference, so the only way to 'P2' is through geographic_area
          list = @ce_p2.counties_hash
          expect(list).to include({'P2' => [@area_p2]}, {'QUP2' => [@area_qup2]})
        end
        specify 'derived from georeference -> geographic_areas chain' do
          # @ce_m2 has no geographic_area, so the only way to 'M2' is through georeference
          expect(@ce_m2.counties_hash).to eq({'M2' => [@area_m2]})
        end
      end

      context 'when more than one possible name is present' do

        specify 'derived from geographic_area_chain' do
          # @ce_n1 has no georeference, so the only way to 'N1' is through geographic_area
          list = @ce_n1.counties_hash
          expect(list).to include({'N1' => [@area_n1]}, {'QTN1' => [@area_qtn1]}) #
          #  'Great Northern Land Mass' contains 'Q', and thus n1, but is NOT type 'County'
          expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
        end
        specify 'derived from georeference -> geographic_areas chain' do
          # @ce_m1 has no geographic_area, so the only way to 'M1' is through georeference
          list = @ce_m1.counties_hash
          expect(list).to include({'M1' => [@area_m1]}, {'QTM1' => [@area_qtm1]}) #
          #  'Great Northern Land Mass' contains 'Q', and thus p1, but is NOT type 'Country'
          expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
        end
      end
    end

    context '#county_name' do
      context 'derivation priority' do
        specify 'it should return nil when no georeference or CollectingEvent#geographic_area_id is present' do
          # @ce_v is the right CE for this test.
          expect(@ce_v.county_name).to be_nil
        end
        specify 'it should return the value derived from the georeference "chain" if both present' do
          # @ce_p1 has a GR, and a GA.
          expect(@ce_p1.county_name).to eq('P1')
        end
        specify 'it should return the value derived from the geographic_area chain if georeference chain is not present' do
          # @ce_n1 has no GR.
          expect(@ce_n1.county_name).to eq('N1')
        end
      end

      context 'result priority' do
        specify 'it should return #counties_hash.keys.first when only one key is present' do
          # @ce_o1 leads to only one GA (named area).
          expect(@ce_o1.county_name).to eq('O1')
        end
        specify 'it should return the #counties_hash.key that has the most #countries_hash.values if more than one present' do
          # @ce_n2 leads back to three GAs; 'N2', and two named 'QTN2'.
          expect(@ce_n2.county_name).to eq('QTN2')
        end
        specify 'it should return the first #counties_hash.key when an equal number of .values is present' do
          # @ce_o2 leads back to two GAs; 'O2', and 'QUO2'
          expect(@ce_o2.county_name).to eq('O2')
        end
      end
    end
  end

end
