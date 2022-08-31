require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe CollectingEvent, type: :model, group: [:geo, :shared_geo, :collecting_event] do

  include_context 'stuff for complex geo tests'

  let(:collecting_event) { CollectingEvent.new }
  let(:county) { FactoryBot.create(:valid_geographic_area_stack) }
  let(:state) { county.parent }
  let(:country) { state.parent }


  specify '#preferred_georeference 1' do
    collecting_event.save!
    expect(collecting_event.preferred_georeference).to eq(nil)
  end

  specify '#preferred_georeference 2' do
    collecting_event.save!
    a = Georeference::Wkt.create!(wkt: 'POINT (99 99)', collecting_event: collecting_event)
    expect(collecting_event.preferred_georeference).to eq(a)
  end

  specify '#preferred_georeference 3, latests is at top' do
    collecting_event.save!
    a = FactoryBot.create(:valid_georeference_verbatim_data, collecting_event: collecting_event)
    expect(collecting_event.preferred_georeference).to eq(a)
  end

  specify '#preferred_georeference 3' do
    collecting_event.save!
    a = Georeference::Wkt.create!(wkt: 'POINT (10 10)', collecting_event: collecting_event)
    b = FactoryBot.create(:valid_georeference_verbatim_data, collecting_event: collecting_event)
    expect(collecting_event.preferred_georeference.reload).to eq(b)
  end

  context 'with political areas and collecting events generated' do
    context 'geographic names' do
      before { collecting_event.save! }

      context '#geographic_name_classification_method' do
        specify 'with no data #geographic_name_classification_method returns nil' do
          expect(collecting_event.geographic_name_classification_method).to eq(nil)
        end

        specify 'with a georeference set #geographic_name_classification_method returns :preferred_georeference' do
          collecting_event.georeferences << FactoryBot.create(:valid_georeference)
          expect(collecting_event.geographic_name_classification_method).to eq(:preferred_georeference)
        end

        specify 'with a geographic area that has a shape set #geographic_name_classification_method returns :geographic_area_with_shape' do
          country.geographic_items << FactoryBot.create(:geographic_item_with_polygon)
          collecting_event.update_column(:geographic_area_id, country.id)

          expect(collecting_event.geographic_name_classification_method).to eq(:geographic_area_with_shape)
        end

        specify 'with #geographic_area (no shape) set #geographic_name_classification returns :geographic_area' do
          collecting_event.update_column(:geographic_area_id, state.id) 
          expect(collecting_event.geographic_name_classification_method).to eq(:geographic_area)
        end
      end

      context 'caching' do
        context 'with no data' do
          specify '#geographic_names returns {}' do
            expect(collecting_event.geographic_names).to eq({})
          end
        end

        context 'with a verbatim georeference' do
          before { [area_e, area_a].each
          collecting_event.update!(
            verbatim_latitude:  '5.0',
            verbatim_longitude: '5.0'
          )
          Georeference::VerbatimData.create!(collecting_event: collecting_event)
          }

          specify 'country, state, county are cached on creation of georeference' do
            # expect(collecting_event.cached_geographic_name_classification).to eq( {:country=>"West Boxia",
            # :state=>"QT", :county=>"M1"} )
            expect(collecting_event.geographic_names).to eq({country: 'E', state: 'A'})
          end
        end

        context 'after record is updated, cached values are set' do
          context 'with a geographic_area (no shape) set to country (level0)' do
            before do
              collecting_event.update(geographic_area_id: country.id)
            end

            specify '#geographic_names returns { country: country_name }' do
              expect(collecting_event.geographic_names).to eq({country: country.name})
            end
          end

          context 'with a geographic_area (no shape) set to state (level1)' do
            before do
              collecting_event.update(geographic_area_id: state.id)
            end

            specify '#cached_geographic_name_classification returns { country: country_name, state: state_name }' do
              expect(collecting_event.geographic_names).to eq({country: country.name,
                                                               state:   state.name})
            end
          end

          context 'with a geographic_area (no shape) set to county (level2)' do
            before do
              collecting_event.update(geographic_area_id: county.id)
            end

            specify '#geographic_names returns { country: country_name, state: state_name, county: county_name }' do
              expect(collecting_event.geographic_names).to eq(
                {country: country.name,
                 state: state.name,
                 county: county.name})
            end
          end

          context 'cached values are updated after geographic_area_id is updated' do
            before do
              collecting_event.update(geographic_area_id: county.id)
              collecting_event.update(geographic_area_id: state.id)
            end

            specify '#cached_geographic_name_classification returns { country: country_name, state: state_name }' do
              expect(collecting_event.geographic_names).to eq(
                {country: country.name,
                 state: state.name})
            end
          end

          context 'cached values are NOT updated when no_cache: true' do
            before do
              collecting_event.no_cached = true
              collecting_event.update_attribute(:geographic_area_id, county.id)
            end

            specify '#geographic_names returns {  }' do
              expect(collecting_event.geographic_names).to eq({})
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
            collecting_event.geographic_area = area_a
          }

          specify '#map_center_method' do
            expect(collecting_event.map_center_method).to eq(:geographic_area)
          end

          specify 'return geographic area centroid' do
            # check to see if geo_object has native centroid method
            expect(collecting_event.map_center).to eq(area_a.default_geographic_item.geo_object.centroid)
          end

          context 'verbatim_map_center provided' do
            before {
              collecting_event.verbatim_latitude  = '1.0'
              collecting_event.verbatim_longitude = '2.0'
            }

            specify '#map_center_method' do
              expect(collecting_event.map_center_method).to eq(:verbatim_map_center)
            end

            specify 'return verbatim_map_center' do
              # Gis::FACTORY.point('2.0', '1.0')
              expect(collecting_event.map_center).to eq(collecting_event.verbatim_map_center)
            end

            context 'georeference provided' do
              before {
                collecting_event.save!

                FactoryBot.create(:georeference_verbatim_data,
                                  collecting_event: collecting_event,
                                  geographic_item: GeographicItem.new(point: area_a.default_geographic_item
                                                                                .centroid))
                collecting_event.reload
              }

              specify '#map_center_method' do
                expect(collecting_event.map_center_method).to eq(:preferred_georeference)
              end

              specify 'return georeference#geographic_item centroid' do
                expect(collecting_event.map_center).to eq(area_a.default_geographic_item.centroid)
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
      collecting_event.verbatim_latitude  = '1.0'
      collecting_event.verbatim_longitude = '2.0'
      expect(collecting_event.verbatim_map_center).to eq(Gis::FACTORY.point('2.0', '1.0'))
    end
  end

  context 'georeferences' do
    context 'when the CE has a GR' do
      context 'and that GR has some combination of GIs, and EGIs' do
        before { [gr_a, gr_b].each }
        # pending 'fixing the bug in all_geographic_items' # todo: @mjy
        specify 'that the count of which can be found' do
          # ce_a
          expect(ce_a.all_geographic_items).to contain_exactly(p_a, new_box_a)
        end

        specify 'that the count of which can be found' do
          # ce_b
          expect(ce_b.all_geographic_items).to contain_exactly(err_b, p_b)
        end

        specify 'that the count of which can be found' do
          # ce_area_v has no GR or GA.
          expect(ce_area_v.all_geographic_items.count).to eq(0)
        end
      end

      context 'and that GR has a GI but no EGI' do
        before { [gr_a, gr_b, ce_area_v].each }

        context 'find other CEs that have GRs whose GI or EGI is within some radius of the source GI' do
          specify 'ce_b' do
            ce_a.reload
            expect(ce_a.collecting_events_within_radius_of(2_000_000)).to include(ce_b)
          end

          specify 'ce_area_v' do
            expect(ce_a.collecting_events_within_radius_of(2_000_000)).not_to include(ce_area_v)
          end
        end

        context 'find other CEs that have GRs whose GI or EGI intersects the source GI' do
          before { [gr02s, gr121s, gr01s, gr11s, gr03s, gr13s, gr_a].each }

          specify 'ce_p1s, ce_p3s' do
            expect(ce_p2s.collecting_events_intersecting_with).to contain_exactly(ce_p1s, ce_p3s)
          end

          specify 'not ce_a' do
            expect(ce_p2s.collecting_events_intersecting_with).not_to include(ce_a) # even though @p17 is close to @k
          end
        end
      end

      context 'and that GR has both GI and EGI' do
        before { [gr02s, gr121s, gr01s, gr11s, gr03s, gr13s, gr_a].each }
        context 'find other CEs that have GR whose GIs are within some radius' do
          # was: 'find other CEs that have GR whose GIs or EGIs are within some radius of the EGI'
          specify 'ce_p3s, ce_s, ce_p1s' do
            expect(ce_p2s.collecting_events_within_radius_of(1000000)).to contain_exactly(ce_p1s, ce_p3s)
          end
          specify 'ce_p3s, ce_s, ce_p1s' do
            expect(ce_p2s.collecting_events_within_radius_of(1000000)).not_to include(ce_a)
          end
        end

        context 'find other CEs that have GRs whose GIs or EGIs are contained in the EGI' do
          specify 'ce_p3s, ce_p2s, ce_p1s' do
            # skip 'contained in error_gi'
            expect(ce_p1s.collecting_events_contained_in_error).to contain_exactly(ce_p3s, ce_p2s)
          end
          specify 'ce_p3s, ce_p2s, ce_p1s' do
            # skip 'contained in error_gi'
            expect(ce_p1s.collecting_events_contained_in_error).not_to include(ce_p1s)
          end
        end
      end

      context 'geolocate responses from collecting_event' do
        # rubocop:disable Style/StringHashKeys

        context 'geolocate_ui_params' do
          specify 'geolocate_ui_params from locality' do
            # @ce_n3 was built with locality, with no verbatim_lat/long
            expect(ce_a.geolocate_ui_params).to eq(
              {'country'       => 'E',
               'state'         => 'A',
               'county'        => nil,
               'locality'      => 'environs of A',
               'Latitude'      => 5.0,
               'Longitude'     => 5.0,
               'Placename'     => 'environs of A',
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
               'gc'            => 'TaxonWorks'
              })
          end

          specify 'geolocate_ui_params from lat/long' do
            # @ce_m1.georeference was built from verbatim data; no locality
            expect(ce_b.geolocate_ui_params).to eq(
              {'country'       => 'E',
               'state'         => nil,
               'county'        => 'B',
               'locality'      => 'environs of B',
               'Latitude'      => -5.0,
               'Longitude'     => 5.0,
               'Placename'     => 'environs of B',
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
               'gc'            => 'TaxonWorks'
              })
          end
        end

        context 'geolocate_ui_params_string' do

          specify 'geolocate_ui_params_string from locality' do
            #pending 'creation of a method for geolocate_ui_params_string'
            expect(ce_a.geolocate_ui_params_string).to eq(
              'http://www.geo-locate.org/web/' \
              'webgeoreflight.aspx?country=E&state=A' \
              '&county=&locality=environs of A' \
              '&points=5.0|5.0|environs of A|0|3' \
              '&georef=run|false|false|true|true|false|false|false|0' \
              '&gc=TaxonWorks')
          end

          specify 'geolocate_ui_params_string from lat/long' do
            #pending 'creation of a method for geolocate_ui_params_string'
            expect(ce_b.geolocate_ui_params_string).to eq(
              'http://www.geo-locate.org/web/' \
              'webgeoreflight.aspx?country=E&state=' \
              '&county=B&locality=environs of B' \
              '&points=-5.0|5.0|environs of B|0|3' \
              '&georef=run|false|false|true|true|false|false|false|0' \
              '&gc=TaxonWorks')
          end
        end
      end
    end
  end

  context 'creating a collecting event with no resolvable geographic_names' do
    let(:earth) { FactoryBot.create(:earth_geographic_area) }

    specify 'succeeds without entering a nasty loop' do
      CollectingEvent.create!(geographic_area: earth)
      expect(CollectingEvent.last.geographic_names).to eq({})
    end
  end


  context 'georeferences' do
    context 'verbatim georeferences using with_verbatim_data_georeference: true' do
      context 'on new()' do
        specify 'creates a verbatim georeference using new()' do
          c = CollectingEvent.create!(verbatim_latitude:               '10.001',
                                      verbatim_longitude:              '10',
                                      project:                         geo_project,
                                      with_verbatim_data_georeference: true)
          expect(c.verbatim_data_georeference.id).to be_truthy
        end
      end

      context 'on create()' do
        let(:c) { CollectingEvent.create!(
          verbatim_latitude: '10.001',
          verbatim_longitude: '10',
          project: geo_project,
          with_verbatim_data_georeference: true) }

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
        c = CollectingEvent.create!(verbatim_latitude:               '10.001',
                                    verbatim_longitude:              '10',
                                    project:                         geo_project,
                                    with_verbatim_data_georeference: true)
        # ! do points have to be decimalized?
        expect(c.verbatim_data_georeference.geographic_item.geo_object.to_s).to eq('POINT (10.0 10.001 0.0)')
      end

      context 'using by cascades creator/updater to georeference and geographic_item' do
        let(:other_user) { FactoryBot.create(:valid_user, name: 'other', email: 'other@test.com') }
        let(:c) { CollectingEvent.create(
          verbatim_latitude:  '10.001',
          verbatim_longitude: '10',
          project: geo_project,
          with_verbatim_data_georeference: true, by: other_user) }

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
    # include_context 'stuff for complex geo tests'

    context 'countries' do
      context 'should return hash of the country with #countries_hash' do
        context 'when one possible name is present' do
          context 'derived from geographic_area_chain' do

            specify 'area E' do
              # @ce_a has no georeference, so the only way to 'E' is through geographic_area
              expect(ce_b.countries_hash).to include({'E' => [area_e]})
            end

            specify 'area A' do
              # @ce_a has no geographic_area, so the only way to 'A' is through georeference
              expect(ce_b.countries_hash).to_not include({'A' => [area_a]})
            end
          end
        end

        # specify 'derived from geographic_area_chain' do
        #   # 'Q' is synonymous with 'Big Boxia'
        #   # @ce_n1 has no georeference, so the only way to 'Q' is through geographic_area
        #   list = @ce_n1.countries_hash
        #   expect(list).to include({'Q' => [@area_q]})
        #   expect(list).to include({'Old Boxia' => [@area_old_boxia]})
        #   expect(list).to include({'Big Boxia' => [@area_big_boxia]})
        #   #  'Great Northern Land Mass' contains 'Q', and thus m1, but is NOT type 'Country'
        #   expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
        #   end
        context 'when more than one possible name is present' do
          context 'derived from geographic_area_chain' do
            specify 'area Q' do
              [area_q].each
              # 'E' is synonymous with 'R2'
              # ce_n1 has no georeference, so the only way to 'Q' is through geographic_area
              expect(ce_n1.countries_hash).to include({'Q' => [area_q]})
            end
            specify 'area Old Boxia' do
              [area_old_boxia].each
              # 'E' is synonymous with 'R2'
              # ce_n1 has no georeference, so the only way to 'E' is through geographic_area
              expect(ce_n1.countries_hash).to include({'Old Boxia' => [area_old_boxia]})
            end
            specify 'area Big Boxia' do
              [area_big_boxia].each
              # 'E' is synonymous with 'R2'
              # ce_n1 has no georeference, so the only way to 'E' is through geographic_area
              expect(ce_n1.countries_hash).to include({'Big Boxia' => [area_big_boxia]})
            end
            specify 'not Great Northern Land Mass' do
              [area_land_mass].each
              # 'E' is synonymous with 'R2'
              # ce_n1 has no georeference, so the only way to 'E' is through geographic_area
              #  'L2' is outside R2
              expect(ce_n1.countries_hash).to_not include({'Great Northern Land Mass' => [area_land_mass]})
            end
          end

          context 'derived from georeference in P1B' do
            # @ce_p1 has both geographic_area and georeference; georeference has priority
            specify 'derived from georeference -> geographic_areas chain - Q' do
              [gr_p1b].each
              expect(ce_p1b.countries_hash).to include({'Q' => [area_q]})
            end

            specify 'derived from georeference -> geographic_areas chain - Big Boxia' do
              [gr_p1b, area_big_boxia].each
              expect(ce_p1b.countries_hash).to include({'Big Boxia' => [area_big_boxia]})
            end

            specify 'derived from georeference -> geographic_areas chain - East Boxia' do
              [gr_p1b, area_east_boxia_1].each
              expect(ce_p1b.countries_hash.keys).to include('East Boxia')
            end

            specify 'derived from georeference -> geographic_areas chain - East Boxia new and ols names' do
              [gr_p1b, area_east_boxia_1, area_east_boxia_2].each
              expect(ce_p1b.countries_hash['East Boxia']).to include()
            end

            specify 'derived from georeference -> geographic_areas chain - NOT GNLM' do
              #  'Great Northern Land Mass' contains 'Q', and thus p1b, but is NOT type 'Country'
              gr_p1b
              expect(ce_p1b.countries_hash).to_not include({'Great Northern Land Mass' => [area_land_mass]})
            end
          end
        end
      end

      context '#country_name' do
        context 'derivation priority' do
          specify 'it should return nil when no georeference or CollectingEvent#geographic_area_id is present' do
            # @ce_area_v is the right CE for this test.
            expect(ce_area_v.country_name).to be_nil
          end
          specify 'it should return the value derived from the georeference "chain" if both present' do
            # ce_o1 has a GR, and a GA, and leads to 'Big Boxia', 'East Boxia', and 'Q'
            area_big_boxia
            expect(ce_o1.country_name).to eq('Big Boxia') # 'Big Boxia' is alphabetically first
          end
          specify 'it should return the value derived from the geographic_area chain if georeference chain is ' \
                  'not present' do
            # ce_o3 has no GR.
            expect(ce_o3.country_name).to eq('S')
          end
        end

        context 'result priority' do
          specify 'it should return #countries_hash.keys.first when only one key is present' do
            # @ce_o3 leads to only one GA (named area).
            expect(ce_o3.country_name).to eq('S')
          end

          specify 'it should return the #countries_hash.key that has the most ' \
                  '#countries_hash.values if more than one present' do
            [area_old_boxia, area_big_boxia].each
            # @ce_n2 leads back to three GAs; 'Q', 'Big Boxia', and 'Old Boxia'
            expect(ce_n2.country_name).to eq('Big Boxia') # alphabetic ordering
          end

          specify 'it should return the #countries_hash.key that has the most ' \
                  '#countries_hash.values if more than one present' do
            [area_east_boxia_1, area_east_boxia_2, area_big_boxia].each
            # @ce_p1 leads to 'Q', 'Big Boxia', and 'East Boxia', which has two areas. This fact causes
            #   'East Boxia' to be selected over the alphabetically first 'Big Boxia'
            expect(ce_p1b.country_name).to eq('East Boxia')
          end

          specify 'it should return the first #countries_hash.key when an equal number of .values is present' do
            area_old_boxia
            # @ce_n3 leads back to two GAs; 'R', and 'Old Boxia'
            expect(ce_n3.country_name).to eq('Old Boxia') # alphabetic ordering
          end
        end
      end
    end

    context 'states' do
      context 'should return hash of the state with #states_hash' do
        context 'when one possible name is present' do
          specify 'derived from geographic_area_chain' do
            area_so3
            # @ce_o3 has no georeference, so the only way to 'O3' is through geographic_area
            expect(ce_o3.states_hash).to include({'O3' => [area_o3]}, {'SO3' => [area_so3]})
          end
          specify 'derived from geographic_area_chain' do
            area_east_boxia_3
            # @ce_p2 has no georeference, so the only way to 'U' is through geographic_area
            expect(ce_p2b.states_hash).to include({'QU' => [area_u]}, {'East Boxia' => [area_east_boxia_3]})
          end
          specify 'derived from georeference -> geographic_areas chain' do
            [gr_n4, area_rn4, area_n4].each
            # @ce_n4 has no geographic_area, so the only way to 'N4' is through georeference
            expect(ce_n4.states_hash).to include({'N4' => [area_n4]}, {'RN4' => [area_rn4]})
          end
          specify 'derived from georeference -> geographic_areas chain' do
            # @ce_n4 has no geographic_area, so the only way to 'T' is through georeference
            expect(ce_n2.states_hash.keys).to include('QT')
          end
          specify 'derived from georeference -> geographic_areas chain' do
            [gr_n2_a, gr_n2_b, area_t_2].each
            # @ce_n4 has no geographic_area, so the only way to 'T' is through georeference
            expect(ce_n2.states_hash['QT']).to include(area_t_1, area_t_2)
          end
        end

        context 'when more than one possible name is present' do
          specify 'derived from geographic_area_chain' do
            # 'T' is a state in 'Q'
            expect(ce_m1.states_hash.keys).to include('QT')
          end
          specify 'derived from geographic_area_chain' do
            [area_t_2].each
            # 'T' is a state in 'Q'
            expect(ce_m1.states_hash['QT']).to include(area_t_1, area_t_2)
          end
          specify 'derived from georeference -> geographic_areas chain' do
            [gr_p1b, area_east_boxia_1, area_east_boxia_2, area_east_boxia_3].each
            # @ce_p1 has both geographic_area and georeference; georeference has priority
            expect(ce_p1b.states_hash.keys).to include('QU', 'East Boxia')
          end
        end
      end

      context '#state_name' do
        context 'derivation priority' do
          specify 'it should return nil when no georeference or CollectingEvent#geographic_area_id is present' do
            # @ce_v is the right CE for this test.
            expect(ce_v.state_name).to be_nil
          end
          specify 'it should return the value derived from the georeference "chain" if both present' do
            [area_east_boxia_3].each
            # @ce_p1 has a GR, and a GA. 'East Boxia' and 'QU' will be the found names
            expect(ce_p1b.state_name).to eq('East Boxia') # 'East Boxia' is alphabetically first.
          end
          specify 'it should return the value derived from the geographic_area chain if ' \
                  'georeference chain is not present' do
            # @ce_o3 has no GR.
            expect(ce_o3.state_name).to eq('O3')
          end
        end

        context 'result priority' do
          specify 'it should return #states_hash.keys.first when only one key is present' do
            # @ce_o3 leads to only one GA (named area).
            expect(ce_o3.state_name).to eq('O3')
          end
          specify 'it should return the #states_hash.key that has the most #countries_hash.values ' \
                  'if more than one present' do
            # @ce_n2 leads back to three GAs; 'Q', 'Big Boxia', and 'Old Boxia'
            expect(ce_n2.state_name).to eq('QT')
          end
          specify 'it should return the first #states_hash.key when an equal number of .values is present' do
            # @ce_n3 is state names 'N3', and leads back to two GAs; 'R', and 'Old Boxia'
            expect(ce_n3.state_name).to eq('N3')
          end
        end
      end
    end

    context 'counties' do
      context 'should return hash of the county with #counties_hash' do
        context 'when one possible name is present' do
          specify 'derived from geographic_area_chain' do
            [area_qup2].each
            # @ce_p2 has no georeference, so the only way to 'P2' is through geographic_area
            expect(ce_p2b.counties_hash).to include({'P2' => [area_p2b]}, {'QUP2' => [area_qup2]})
          end
          specify 'derived from georeference -> geographic_areas chain' do
            [area_m2, gr_m2].each
            # @ce_m2 has no geographic_area, so the only way to 'M2' is through georeference
            expect(ce_m2.counties_hash).to eq({'M2' => [area_m2]})
          end
        end

        context 'when more than one possible name is present' do

          specify 'derived from geographic_area_chain' do
            [area_qtn1].each
            # @ce_n1 has no georeference, so the only way to 'N1' is through geographic_area
            expect(ce_n1.counties_hash).to include({'N1' => [area_n1]}, {'QTN1' => [area_qtn1]}) #
          end
          specify 'derived from geographic_area_chain' do
            #  'Great Northern Land Mass' contains 'Q', and thus n1, but is NOT type 'County'
            expect(ce_n1.counties_hash).to_not include({'Great Northern Land Mass' => [area_land_mass]})
          end
          specify 'derived from georeference -> geographic_areas chain' do
            [area_qtm1].each
            # @ce_m1 has no geographic_area, so the only way to 'M1' is through georeference
            expect(ce_m1.counties_hash).to include({'M1' => [area_m1]}, {'QTM1' => [area_qtm1]}) #
          end
          specify 'derived from georeference -> geographic_areas chain' do
            #  'Great Northern Land Mass' contains 'Q', and thus p1, but is NOT type 'Country'
            expect(ce_m1.counties_hash).to_not include({'Great Northern Land Mass' => [area_land_mass]})
          end
        end
      end
      # rubocop:enable Style/StringHashKeys

      context '#county_name' do
        context 'derivation priority' do
          specify 'it should return nil when no georeference or CollectingEvent#geographic_area_id is present' do
            # @ce_v is the right CE for this test.
            expect(ce_v.county_name).to be_nil
          end
          specify 'it should return the value derived from the georeference "chain" if both present' do
            # @ce_p1 has a GR, and a GA.
            expect(ce_p1b.county_name).to eq('P1B')
          end
          specify 'it should return the value derived from the geographic_area chain if ' \
                    'georeference chain is not present' do
            # @ce_n1 has no GR.
            expect(ce_n1.county_name).to eq('N1')
          end
        end

        context 'result priority' do
          specify 'it should return #counties_hash.keys.first when only one key is present' do
            # @ce_o1 leads to only one GA (named area).
            expect(ce_o1.county_name).to eq('O1')
          end
          specify 'it should return the #counties_hash.key that has the most ' \
                    '#countries_hash.values if more than one present' do
            [area_qtn2_1, area_qtn2_2].each
            # @ce_n2 leads back to three GAs; 'N2', and two named 'QTN2'.
            expect(ce_n2.county_name).to eq('QTN2')
          end
          specify 'it should return the first #counties_hash.key when an equal number of .values is present' do
            # @ce_o2 leads back to two GAs; 'O2', and 'QUO2'
            expect(ce_o2.county_name).to eq('O2')
          end
        end
      end
    end
  end
end
