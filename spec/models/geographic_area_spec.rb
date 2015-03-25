require 'rails_helper'

# TODO:   Where/how to generate the real GeoJSON (RGeo::GeoJSON.encode(object) does not seem to work properly)

describe GeographicArea, type: :model, group: :geo do
  let(:geographic_area) { FactoryGirl.build(:geographic_area_stack) }

  context 'validation' do
    before(:each) {
      geographic_area.valid?
    }

    context 'required fields' do
      specify 'name' do
        expect(geographic_area.errors.include?(:name)).to be_truthy
      end

      specify 'blank names are invalid' do
        geographic_area.name = ''
        geographic_area.valid?
        expect(geographic_area.errors.include?(:name)).to be_truthy
      end

      specify 'names are minimum length' do
        geographic_area.name = '1'
        geographic_area.valid?
        expect(geographic_area.errors.include?(:name)).to be_falsey
      end

      specify 'data_origin' do
        expect(geographic_area.errors.include?(:data_origin)).to be_truthy
      end

      specify 'geographic_area_type' do
        expect(geographic_area.errors.include?(:geographic_area_type)).to be_truthy
      end
    end
  end

  context 'instance methods' do
    specify "#tdwg_ids" do
      geographic_area.tdwgID = '41SCS-PI'
      expect(geographic_area.tdwg_ids[:lvl1]).to eq('4')
      expect(geographic_area.tdwg_ids[:lvl2]).to eq('41')
      expect(geographic_area.tdwg_ids[:lvl3]).to eq('SCS')
      expect(geographic_area.tdwg_ids[:lvl4]).to eq('SCS-PI')
    end

    specify "#tdwg_level" do
      geographic_area.data_origin = 'TDWG2 Level 1'
      expect(geographic_area.tdwg_level).to eq('1')
    end
  end

  context 'associations' do
    context 'belongs_to' do
      specify 'parent' do
        expect(geographic_area).to respond_to(:parent)
      end

      specify 'level0' do
        expect(geographic_area).to respond_to(:level0)
      end
      specify 'level1' do
        expect(geographic_area).to respond_to(:level1)
      end
      specify 'level2' do
        expect(geographic_area).to respond_to(:level2)
      end

      specify 'geo_object' do
        expect(geographic_area).to respond_to(:geo_object)
      end

      context 'has_many' do
        specify 'children_at_level1' do
          expect(geographic_area).to respond_to(:children_at_level1)
        end
        specify 'children_at_level2' do
          expect(geographic_area).to respond_to(:children_at_level2)
        end
      end
    end

    context 'nesting' do
      context 'parents' do
        before(:each) {
          @champaign = FactoryGirl.create(:level2_geographic_area)
        }

        specify 'lft, rgt' do
          expect(@champaign.lft > 0).to be_truthy
          expect(@champaign.rgt > 0).to be_truthy
        end

        specify 'parent string' do
          expect(@champaign.name).to eq('Champaign')
          expect(@champaign.parent.name).to eq('Illinois')
          expect(@champaign.parent.parent.name).to eq('United States of America')
          expect(@champaign.parent.parent.parent.name).to eq('Earth')
        end

        specify 'ancestors' do
          expect(@champaign.ancestors).to eq([@champaign.root, @champaign.parent.parent, @champaign.parent])
        end

        specify 'root' do
          expect(@champaign.root.name).to eq('Earth')
        end

        specify 'descendants' do
          expect(@champaign.root.descendants.count).to eq(3)
        end
      end
    end
  end

  context 'search functions' do
    before(:each) {
      @champaign = FactoryGirl.create(:level2_geographic_area)
      @illinois  = @champaign.parent
      @usa       = @illinois.parent
      @earth     = @usa.parent
    }

    specify 'should be able to find a country by ISO_A2' do
      expect(GeographicArea.where(:iso_3166_a2 => 'US').first.name).to eq('United States of America')
    end

    specify 'should be able to find a country by ISO_A3' do
      expect(GeographicArea.where(:iso_3166_a3 => 'USA').first.name).to eq('United States of America')
    end

    context 'scopes/AREL' do
      specify 'children_at_level1' do
        expect(@champaign.children_at_level1.count).to eq(0)
        expect(@champaign.root.children_at_level1.count).to eq(1)
        expect(@champaign.parent.parent.children_at_level1.count).to eq(1)
      end

      specify 'children_at_level2' do
        expect(@champaign.children_at_level2.count).to eq(0)
        expect(@champaign.root.children_at_level2.count).to eq(1)
        expect(@champaign.parent.children_at_level2.count).to eq(1)
      end

      specify 'descendants_of' do
        expect(GeographicArea.descendants_of(@champaign.root)).to eq([@champaign.parent.parent, @champaign.parent, @champaign])
      end

      specify 'ancestors_of' do
        expect(GeographicArea.ancestors_of(@champaign)).to eq([@champaign.root, @champaign.parent.parent, @champaign.parent])
      end

      specify 'ancestors_and_descendants_of' do
        expect(GeographicArea.ancestors_and_descendants_of(@illinois)).to eq([@champaign.root, @champaign.parent.parent, @champaign])
      end

      specify 'countries' do
        expect(GeographicArea.countries).to include(@champaign.parent.parent)
      end

      specify 'descendants_of_geographic_area_type' do
        expect(@champaign.root.descendants_of_geographic_area_type('County').to_a).to eq([@champaign])
        expect(@champaign.root.descendants_of_geographic_area_type('State').to_a).to eq([@champaign.parent])
        expect(@champaign.root.descendants_of_geographic_area_type('Province').to_a).to eq([])
      end

      specify 'descendants_of_geographic_area_types' do
        expect(@champaign.root.descendants_of_geographic_area_types(['County', 'State', 'Province']).to_a).to eq([@champaign.parent, @champaign])
      end

      specify '::with_name_and_parent_name' do
        # single immediate parent name
        expect(GeographicArea.with_name_and_parent_name(%w(Champaign Illinois)).to_a).to eq([@champaign])
        # single immediate parent name not in list
        expect(GeographicArea.with_name_and_parent_name(%w(Champaign Ohio)).to_a).to eq([])
      end

      specify '::with_name_and_parent_names' do
        # multiple parent name
        expect(GeographicArea.with_name_and_parent_names(%w(Champaign Illinois United\ States\ of\ America)).to_a).to eq([@champaign])
        # multiple parent name not in list
        expect(GeographicArea.with_name_and_parent_names(%w(Champaign Ohio United\ States\ of\ America)).to_a).to eq([])
      end

      specify '::find_by_self_and_parents' do
        # one name
        expect(GeographicArea.find_by_self_and_parents(%w(Champaign)).to_a).to eq([@champaign])
        # two names
        expect(GeographicArea.find_by_self_and_parents(%w(Champaign Illinois)).to_a).to eq([@champaign])
        # three names
        expect(GeographicArea.find_by_self_and_parents(%w(Champaign Illinois United\ States\ of\ America)).to_a).to eq([@champaign])
        # two names not in list
        expect(GeographicArea.find_by_self_and_parents(%w(Champaign Ohio)).to_a).to eq([])
        # three names not in list
        expect(GeographicArea.find_by_self_and_parents(%w(Champaign Ohio United\ States\ of\ America)).to_a).to eq([])

      end
    end
  end

  # TODO: cleanup/extend
  context 'interaction with geographic_items' do
    # after(:all) {
    #   GeographicArea.destroy_all
    # }
    before(:each) {
      @geographic_area = FactoryGirl.create(:level2_geographic_area)
      @gi              = GeographicItem.create!(polygon: RSPEC_GEO_FACTORY.polygon(LIST_K))
      @geographic_area.geographic_areas_geographic_items << GeographicAreasGeographicItem.new(geographic_item: @gi, data_origin: 'SFG')
      @geographic_area.save
      @gi
    }

    specify 'retrieving the geo_object' do
      expect(@geographic_area.default_geographic_item.to_param).to eq(@gi.to_param)
    end
  end

  context 'geolocate responses from geographic_area' do
    before(:all) {
      @geographic_area    = FactoryGirl.create(:valid_geographic_area_stack)
      @ford_county        = GeographicArea.new(name:                 'Ford',
                                               geographic_area_type: @geographic_area.geographic_area_type,
                                               level1:               @geographic_area.parent,
                                               level0:               @geographic_area.parent.parent,
                                               parent:               @geographic_area.parent,
                                               data_origin:          'Test')
      @ford_county.level2 = @ford_county
      @ford_county.save
      @champaign_county = RSPEC_GEO_FACTORY.parse_wkt(CHAMPAIGN_CO)
      @geographic_area.geographic_items << GeographicItem.new(multi_polygon: @champaign_county)
      @illinois_state = RSPEC_GEO_FACTORY.parse_wkt(ILLINOIS)
      @geographic_area.parent.geographic_items << GeographicItem.new(multi_polygon: @illinois_state)
    }

    after(:all) {
      clean_slate_geo
    }
    
    context 'geolocate_ui_params_hash' do

      specify 'retrieving geolocate UI paramerters as a hash' do
        # pending 'completion of a method for geolocate_ui_params_string'
        expect(@geographic_area.geolocate_ui_params_hash).to eq({country:       'United States of America',
                                                                 state:         'Illinois',
                                                                 county:        'Champaign',
                                                                 locality:      nil,
                                                                 Latitude:      40.1397523583313,
                                                                 Longitude:     -88.199600849246,
                                                                 Placename:     nil,
                                                                 Score:         '0',
                                                                 Uncertainty:   '3',
                                                                 H20:           'false',
                                                                 HwyX:          'false',
                                                                 Uncert:        'true',
                                                                 Poly:          'true',
                                                                 DisplacePoly:  'false',
                                                                 RestrictAdmin: 'false',
                                                                 BG:            'false',
                                                                 LanguageIndex: '0',
                                                                 gc:            'Tester'
                                                                })
        expect(@geographic_area.parent.geolocate_ui_params_hash).to eq({country:       'United States of America',
                                                                        state:         'Illinois',
                                                                        county:        nil,
                                                                        locality:      nil,
                                                                        Latitude:      40.1211151426486,
                                                                        Longitude:     -89.1547189404101,
                                                                        Placename:     nil,
                                                                        Score:         '0',
                                                                        Uncertainty:   '3',
                                                                        H20:           'false',
                                                                        HwyX:          'false',
                                                                        Uncert:        'true',
                                                                        Poly:          'true',
                                                                        DisplacePoly:  'false',
                                                                        RestrictAdmin: 'false',
                                                                        BG:            'false',
                                                                        LanguageIndex: '0',
                                                                        gc:            'Tester'
                                                                       })
        expect(@geographic_area.parent.parent.geolocate_ui_params_hash).to eq({country:       'United States of America',
                                                                               state:         nil,
                                                                               county:        nil,
                                                                               locality:      nil,
                                                                               Latitude:      nil,
                                                                               Longitude:     nil,
                                                                               Placename:     nil,
                                                                               Score:         '0',
                                                                               Uncertainty:   '3',
                                                                               H20:           'false',
                                                                               HwyX:          'false',
                                                                               Uncert:        'true',
                                                                               Poly:          'true',
                                                                               DisplacePoly:  'false',
                                                                               RestrictAdmin: 'false',
                                                                               BG:            'false',
                                                                               LanguageIndex: '0',
                                                                               gc:            'Tester'
                                                                              })
        expect(@geographic_area.parent.parent.parent.geolocate_ui_params_hash).to eq({country:       nil,
                                                                                      state:         nil,
                                                                                      county:        nil,
                                                                                      locality:      nil,
                                                                                      Latitude:      nil,
                                                                                      Longitude:     nil,
                                                                                      Placename:     nil,
                                                                                      Score:         '0',
                                                                                      Uncertainty:   '3',
                                                                                      H20:           'false',
                                                                                      HwyX:          'false',
                                                                                      Uncert:        'true',
                                                                                      Poly:          'true',
                                                                                      DisplacePoly:  'false',
                                                                                      RestrictAdmin: 'false',
                                                                                      BG:            'false',
                                                                                      LanguageIndex: '0',
                                                                                      gc:            'Tester'})
        # this case is to look upwards in the stack for a geographic_item, because this record does not have one,
        # thus providing the parent's centroid.
        expect(@ford_county.geolocate_ui_params_hash).to eq({country:       'United States of America',
                                                             state:         'Illinois',
                                                             county:        'Ford',
                                                             locality:      nil,
                                                             Latitude:      40.1211151426486,
                                                             Longitude:     -89.1547189404101,
                                                             Placename:     nil,
                                                             Score:         '0',
                                                             Uncertainty:   '3',
                                                             H20:           'false',
                                                             HwyX:          'false',
                                                             Uncert:        'true',
                                                             Poly:          'true',
                                                             DisplacePoly:  'false',
                                                             RestrictAdmin: 'false',
                                                             BG:            'false',
                                                             LanguageIndex: '0',
                                                             gc:            'Tester'
                                                            })
      end
    end

    context 'geolocate_ui_params_string' do

      specify 'retrieving geolocate UI parameters as a string' do
        # pending 'completion of a method for geolocate_ui_params_string'
        expect(@geographic_area.geolocate_ui_params_string).to eq('http://www.museum.tulane.edu/geolocate/web/webgeoreflight.aspx?country=United States of America&state=Illinois&county=Champaign&locality=&points=40.1397523583313|-88.199600849246||0|3&georef=run|false|false|true|true|false|false|false|0&gc=Tester')
      end
    end

  end

  context 'find_others... responses from geographic_areas' do

    before(:all) do
      generate_political_areas_with_collecting_events
    end

    after(:all) do
      clean_slate_geo
    end

    specify('is_contained_by') do
      expect(GeographicArea.is_contained_by(@area_old_boxia).map(&:name)).to include('Old Boxia',
                                                                                              'West Boxia',
                                                                                              'QTM1',
                                                                                              'QTM2',
                                                                                              'QTN1',
                                                                                              'QTN2',
                                                                                              'M1',
                                                                                              'QT',
                                                                                              'West Boxia',
                                                                                              'R',
                                                                                              'N1',
                                                                                              'M2',
                                                                                              'RM3',
                                                                                              'RM4',
                                                                                              'RN3',
                                                                                              'RN4',
                                                                                              'M3',
                                                                                              'N3',
                                                                                              'M4',
                                                                                              'N4',
                                                                                              'N2')
    end

    specify('are_contained_in') do
      expect(GeographicArea.are_contained_in(@area_p2).map(&:name)).to include('East Boxia',
                                                                                       'Big Boxia',
                                                                                       'Q',
                                                                                       'QUP2',
                                                                                       'QU',
                                                                                       'P2',
                                                                                       'Great Northern Land Mass')
    end

    specify('find_by_lat_long') do
      point = @gr_n3_ob.geographic_item.geo_object
      expect(GeographicArea.find_by_lat_long(point.y, point.x)).to include(@area_r, @area_rn3, @area_old_boxia, @area_n3, @area_land_mass)
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
