require 'rails_helper'
require 'support/shared_contexts/shared_geo'

# TODO: Where/how to generate the real GeoJSON (RGeo::GeoJSON.encode(object) does not seem to work properly)

describe GeographicArea, type: :model, group: [:geo, :shared_goe] do
  include_context 'stuff for complex geo tests'
  let(:geographic_area) {
    FactoryBot.build(:geographic_area_stack)
  }

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
    context '#tdwg_ids' do
      specify 'level 1' do
        geographic_area.tdwgID = '41SCS-PI'
        expect(geographic_area.tdwg_ids[:lvl1]).to eq('4')
      end
      specify 'level 2' do
        geographic_area.tdwgID = '41SCS-PI'
        expect(geographic_area.tdwg_ids[:lvl2]).to eq('41')
      end
      specify 'level 3' do
        geographic_area.tdwgID = '41SCS-PI'
        expect(geographic_area.tdwg_ids[:lvl3]).to eq('SCS')
      end
      specify 'level 4' do
        geographic_area.tdwgID = '41SCS-PI'
        expect(geographic_area.tdwg_ids[:lvl4]).to eq('SCS-PI')
      end
    end

    specify '#tdwg_level' do
      geographic_area.data_origin = 'TDWG2 Level 1'
      expect(geographic_area.tdwg_level).to eq('1')
    end

    context 'classifying' do
      let!(:county) { FactoryBot.create(:valid_geographic_area_stack) }
      let!(:state) { county.parent }
      let!(:country) { state.parent }

      context '#categorize' do
        specify 'a county' do
          expect(county.categorize).to eq(county: county.name)
        end

        specify 'a state' do
          expect(state.categorize).to eq(state: state.name)
        end

        specify 'a country' do
          expect(country.categorize).to eq(country: country.name)
        end
      end

      context '#geographic_name_classification' do
        specify 'for a country' do
          expect(country.geographic_name_classification).to eq(country: country.name)
        end

        specify 'for a state' do
          expect(state.geographic_name_classification).to eq(country: country.name, state: state.name)
        end

        specify 'for a county' do
          expect(county.geographic_name_classification).to eq(country: country.name,
                                                              state:   state.name,
                                                              county:  county.name)
        end
      end
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
        specify 'parent string' do
          expect(champaign.name).to eq('Champaign')
        end
        specify 'parent string' do
          expect(champaign.parent.name).to eq('Illinois')
        end
        specify 'parent string' do
          expect(champaign.parent.parent.name).to eq('United States of America')
        end
        specify 'parent string' do
          expect(champaign.parent.parent.parent.name).to eq('Earth')
        end

        specify 'ancestors' do
          expect(champaign.ancestors).to eq([champaign.parent, champaign.parent.parent, champaign.root])
        end

        specify 'root' do
          expect(champaign.root.name).to eq('Earth')
        end

        specify 'descendants' do
          expect(champaign.root.descendants.count).to eq(3)
        end
      end
    end
  end

  context 'search functions' do
    before { [usa, ford].each }

    specify 'should be able to find a country by ISO_A2' do
      expect(GeographicArea.where(iso_3166_a2: 'US').first.name).to eq('United States of America')
    end

    specify 'should be able to find a country by ISO_A3' do
      expect(GeographicArea.where(iso_3166_a3: 'USA').first.name).to eq('United States of America')
    end

    context 'scopes/AREL' do
      context 'children_at_level1' do
        specify 'of champaign' do
          expect(champaign.children_at_level1.count).to eq(0)
        end
        specify 'of root' do
          expect(champaign.root.children_at_level1.count).to eq(1)
        end
        specify 'of usa' do
          expect(champaign.parent.parent.children_at_level1.count).to eq(1)
        end
      end

      context 'children_at_level2' do
        specify 'of champaign' do
          expect(champaign.children_at_level2.count).to eq(0)
        end
        specify 'of root' do
          expect(champaign.root.children_at_level2.count).to eq(2)
        end
        specify 'of illinois' do
          expect(champaign.parent.children_at_level2.count).to eq(2)
        end
      end

      context 'descendants and descendants_of' do
        specify 'from root object' do
          expect(GeographicArea.descendants_of(earth)).to contain_exactly(usa,
                                                                          illinois,
                                                                          champaign,
                                                                          ford)
        end

        specify 'from subordinant' do
          expect(illinois.descendants.to_a).to contain_exactly(champaign, ford)
        end
      end

      specify 'ancestors and ancestors_of' do
        # This test is for when order is important
        expect(champaign.ancestors.to_a).to eq([champaign.parent,
                                                champaign.parent.parent,
                                                champaign.parent.parent.parent])
        # This test is for when order is *NOT* important
        expect(GeographicArea.ancestors_of(champaign)).to contain_exactly(champaign.parent.parent.parent,
                                                                          champaign.parent,
                                                                          champaign.parent.parent)
      end

      specify 'ancestors_and_descendants_of' do
        # This test is for when order is *NOT* important
        expect(GeographicArea.ancestors_and_descendants_of(illinois)).to contain_exactly(champaign,
                                                                                         ford,
                                                                                         illinois,
                                                                                         usa,
                                                                                         earth)
        # This test is for when order is important
        # expect(GeographicArea.ancestors_and_descendants_of(illinois).to_a).to eq([illinois,
        #                                                                            earth,
        #                                                                            ford,
        #                                                                            usa,
        #                                                                            champaign])
      end

      specify 'countries' do
        expect(GeographicArea.countries).to include(champaign.parent.parent)
      end

      context 'descendants_of_geographic_area_type' do
        specify 'County' do
          expect(champaign.root.descendants_of_geographic_area_type('County').to_a).to contain_exactly(champaign, ford)
        end
        specify 'State' do
          expect(champaign.root.descendants_of_geographic_area_type('State').to_a).to eq([champaign.parent])
        end
        specify 'Province' do
          expect(champaign.root.descendants_of_geographic_area_type('Province').to_a).to eq([])
        end
      end

      specify 'descendants_of_geographic_area_types' do
        expect(champaign.root.descendants_of_geographic_area_types(['County', 'State', 'Province']).to_a).to   \
          contain_exactly(ford, champaign, illinois)
      end

      context '::with_name_and_parent_name' do
        specify 'Champaign Illinois' do
          # single immediate parent name
          expect(GeographicArea.with_name_and_parent_name(%w(Champaign Illinois)).to_a).to eq([champaign])
        end

        specify 'Champaign Ohio' do
          # single immediate parent name not in list
          expect(GeographicArea.with_name_and_parent_name(%w(Champaign Ohio)).to_a).to eq([])
        end

        specify 'Champaign Illinois' do
          # multiple parent name
          expect(GeographicArea.with_name_and_parent_names(%w(Champaign Illinois United\ States\ of\ America)).to_a)
            .to eq([champaign])
        end

        specify 'Champaign Ohio' do
          # multiple parent name
          expect(GeographicArea.with_name_and_parent_names(%w(Champaign Illinois United\ States\ of\ America)).to_a)
            .to eq([champaign])
        end
      end

      context '::find_by_self_and_parents' do
        specify 'one name' do
          expect(GeographicArea.find_by_self_and_parents(%w(Champaign)).to_a).to eq([champaign])
        end

        specify 'two names' do
          expect(GeographicArea.find_by_self_and_parents(%w(Champaign Illinois)).to_a).to eq([champaign])
        end

        specify 'three names' do
          expect(GeographicArea.find_by_self_and_parents(%w(Champaign Illinois United\ States\ of\ America)).to_a)
            .to eq([champaign])
        end

        specify ' two names not in list' do
          # two names not in list
          expect(GeographicArea.find_by_self_and_parents(%w(Champaign Ohio)).to_a).to eq([])
        end
        specify 'three names not in list' do
          # three names not in list
          expect(GeographicArea.find_by_self_and_parents(%w(Champaign Ohio United\ States\ of\ America)).to_a)
            .to eq([])
        end
      end
    end
  end

  # TODO: cleanup/extend
  context 'interaction with geographic_items' do

    let(:geographic_area) { champaign }
    let(:gi) {
      geographic_area.geographic_areas_geographic_items
      geo_item = GeographicItem::Polygon.create!(polygon: RSPEC_GEO_FACTORY.polygon(list_k))
      geographic_area.geographic_areas_geographic_items.first.destroy!
      geographic_area.geographic_areas_geographic_items << GeographicAreasGeographicItem.new(geographic_item: geo_item,
                                                                                             data_origin:     'SFG')
      geo_item
    }

    specify 'retrieving the geo_object' do
      gi
      expect(geographic_area.default_geographic_item).to eq(gi)
    end
  end

  context 'geolocate responses from geographic_area' do
    context 'geolocate_ui_param' do
# rubocop:disable Style/StringHashKeys
      before {
        [champaign, ford].each
      }

      context 'retrieving geolocate UI paramerters as a hash' do
        specify 'champaign' do
          point = champaign.geolocate_attributes.slice("Latitude", "Longitude")

          # pending 'completion of a method for geolocate_ui_params_string'
          expect(champaign.geolocate_ui_params).to eq({'country'       => 'United States of America',
                                                       'state'         => 'Illinois',
                                                       'county'        => 'Champaign',
                                                       'locality'      => nil,
                                                       'Latitude'      => point['Latitude'],
                                                       'Longitude'     => point['Longitude'],
                                                       'Placename'     => nil,
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
        specify 'illinois' do
          point = champaign.parent.geolocate_attributes.slice("Latitude", "Longitude")
          expect(champaign.parent.geolocate_ui_params).to eq({'country'       => 'United States of America',
                                                              'state'         => 'Illinois',
                                                              'county'        => nil,
                                                              'locality'      => nil,
                                                              'Latitude'      => point['Latitude'],
                                                              'Longitude'     => point['Longitude'],
                                                              'Placename'     => nil,
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
        specify 'usa' do
          expect(champaign.parent.parent.geolocate_ui_params).to eq({'country'       => 'United States of America',
                                                                     'state'         => nil,
                                                                     'county'        => nil,
                                                                     'locality'      => nil,
                                                                     'Latitude'      => nil,
                                                                     'Longitude'     => nil,
                                                                     'Placename'     => nil,
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
        specify 'root' do
          expect(champaign.parent.parent.parent.geolocate_ui_params).to eq({'country'       => nil,
                                                                            'state'         => nil,
                                                                            'county'        => nil,
                                                                            'locality'      => nil,
                                                                            'Latitude'      => nil,
                                                                            'Longitude'     => nil,
                                                                            'Placename'     => nil,
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
                                                                            'gc'            => 'TaxonWorks'})
        end
        specify 'ford' do
          point = ford.geolocate_attributes.slice("Latitude", "Longitude")
          # this case is to look upwards in the stack for a geographic_item, because this record does not have one,
          # thus providing the parent's centroid.
          expect(ford.geolocate_ui_params).to eq({'country'       => 'United States of America',
                                                  'state'         => 'Illinois',
                                                  'county'        => 'Ford',
                                                  'locality'      => nil,
                                                  'Latitude'      => point['Latitude'],
                                                  'Longitude'     => point['Longitude'],
                                                  'Placename'     => nil,
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
# rubocop:enable Style/StringHashKeys

      context 'geolocate_ui_params_string' do

        specify 'retrieving geolocate UI parameters as a string' do
          # pending 'completion of a method for geolocate_ui_params_string'
          ford.geographic_items << GeographicItem::MultiPolygon.create!(multi_polygon: fc_shape)
          point = ford.geolocate_attributes.slice("Latitude", "Longitude").values.join('|')
          expect(ford.geolocate_ui_params_string)
            .to eq('http://www.geo-locate.org/web/webgeoreflight.aspx' \
                '?country=United States of America' \
                '&state=Illinois' \
                '&county=Ford' \
                '&locality=' \
                "&points=#{point}||0|3" \
                '&georef=run|false|false|true|true|false|false|false|0' \
                '&gc=TaxonWorks')
        end
      end
    end
  end

  context 'find_others... responses from geographic_areas' do
    before {
      [big_boxia].each
    }

    specify('is_contained_by') do
      expect(GeographicArea.is_contained_by(area_old_boxia).map(&:name)).to contain_exactly('Old Boxia',
                                                                                            'West Boxia', # country
                                                                                            'West Boxia', # state
                                                                                            'QTM1',
                                                                                            'QTM2',
                                                                                            'QTN1',
                                                                                            'QTN2', # t1
                                                                                            'QTN2', #t2
                                                                                            'M1',
                                                                                            'QT', # t1
                                                                                            'QT', # t2
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
      expect(GeographicArea.are_contained_in(area_p2b).map(&:name)).to contain_exactly(
        'East Boxia', # country
        'East Boxia', # state
        'Big Boxia',
        'Q',
        'QUP2',
        'QU',
        'P2',
        'Great Northern Land Mass')
    end

    specify('#find_by_lat_long') do
      point = gr_n3_ob.geographic_item.geo_object
      expect(GeographicArea.find_by_lat_long(point.y, point.x)).to contain_exactly(
        area_r,
        area_rn3,
        area_old_boxia,
        area_n3,
        area_land_mass)
    end

    specify('#find_smallest_by_lat_long') do
      point = gr_n3_ob.geographic_item.geo_object
      expect(GeographicArea.find_smallest_by_lat_long(point.y, point.x)).to contain_exactly(
        area_r,
        area_rn3,
        area_old_boxia,
        area_n3,
        area_land_mass)
    end
  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
