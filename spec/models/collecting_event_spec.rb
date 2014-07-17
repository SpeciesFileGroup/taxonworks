require 'rails_helper'

describe CollectingEvent do
  before(:all) {
    # generate_geo_test_objects
  }
  let(:collecting_event) { FactoryGirl.build(:collecting_event) }

  context 'validation' do
    specify 'if verbatim_geolocation_uncertainty is provided, then so to are verbatim_longitude and verbatim_latitude' do
      collecting_event.verbatim_geolocation_uncertainty = 'based on my astrolab'
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors.include?(:verbatim_geolocation_uncertainty)).to be_truthy
    end

    specify 'corresponding verbatim_latitude value is provide' do
      collecting_event.verbatim_latitude = '12.345'
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors.include?(:verbatim_longitude)).to be_truthy
    end

    specify 'corresponding verbatim_longitude value is provide' do
      collecting_event.verbatim_longitude = '12.345'
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors.include?(:verbatim_latitude)).to be_truthy
    end

    specify 'start_date_year is valid as 4 digit integer' do
      # You can also pass a string, casting is automatic
      collecting_event.start_date_year = 1942
      collecting_event.valid?
      expect(collecting_event.errors[:start_date_year].size).to eq(0)
    end

    specify 'start_date_year is invalid as 3 digit integer' do
      collecting_event.start_date_year = '194'
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_year)).to be_truthy
    end

    specify 'start_date_year is invalid as when > 5 years from the future' do
      collecting_event.start_date_year = (Time.now.year + 6)
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_year)).to be_truthy
    end

    specify 'start_date_year is invalid when less than 1000' do
      collecting_event.start_date_year = 999
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_year)).to be_truthy
    end

    specify 'end_date_year is valid as 4 digit integer' do
      # You can also pass a string, casting is automatic
      collecting_event.end_date_year = 1942
      collecting_event.valid?
      expect(collecting_event.errors[:end_date_year]).to eq([])
    end

    specify 'end_date_year is invalid as 3 digit integer' do
      collecting_event.end_date_year = '194'
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_year)).to be_truthy
    end

    specify 'end_date_year is invalid as when > 5 years from the future' do
      collecting_event.end_date_year = Time.now.year + 6
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_year)).to be_truthy
    end

    specify 'end_date_year is invalid when less than 1000' do
      collecting_event.end_date_year = 999
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_year)).to be_truthy
    end

    specify 'start_date_month is invalid when not included in LEGAL_MONTHS' do
      ['ab', :jani, 'Febuary', 13, 0].each do |m|
        collecting_event.start_date_month = m
        collecting_event.valid?
        expect(collecting_event.errors.include?(:start_date_month)).to be_truthy
      end
    end

    specify 'start_date_day is invalid when not an integer' do
      collecting_event.start_date_day = "a"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_day)).to be_falsey
    end

    specify 'start_date_day is value bound by month' do
      collecting_event.start_date_year  = "1945" # requires year for leaps
      collecting_event.start_date_month = "2"
      collecting_event.start_date_day   = "30"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_day)).to be_truthy
    end

    specify 'start_date_month is invalid when nil AND start_date_day provided' do
      collecting_event.start_date_day = 1
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_month)).to be_truthy
    end

    specify 'end_date_month is invalid when not included in LEGAL_MONTHS' do
      ['ab', :jani, 'Febuary', 13, 0].each do |m|
        collecting_event.end_date_month = m
        collecting_event.valid?
        expect(collecting_event.errors.include?(:end_date_month)).to be_truthy
      end
    end

    specify 'end_date_day is invalid when not an integer' do
      collecting_event.end_date_day = "a"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_day)).to be_falsey
    end

    specify 'end_date_day is value bound by month' do
      collecting_event.end_date_year  = "1945" # requires year for leaps
      collecting_event.end_date_month = "2"
      collecting_event.end_date_day   = "30"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_day)).to be_truthy
    end

    specify 'end_date_month is invalid when nil AND end_date_day provided' do
      collecting_event.end_date_day = 1
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_month)).to be_truthy
    end

    specify 'end date is > start date when both are provided' do
      message                           = 'End date is earlier than start date.'
      collecting_event.start_date_day   = 2
      collecting_event.start_date_month = 1
      collecting_event.start_date_year  = 1

      collecting_event.end_date_day   = 1
      collecting_event.end_date_month = 1
      collecting_event.end_date_year  = 1

      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors[:base].include?(message)).to be_truthy
    end

    specify 'maximum elevation is greater than minimum elevation when both provided' do
      message                            = 'Maximum elevation is lower than minimum elevation.'
      collecting_event.minimum_elevation = 2
      collecting_event.maximum_elevation = 1
      expect(collecting_event.valid?).to be_falsey
      expect(collecting_event.errors[:maximum_elevation].include?(message)).to be_truthy
    end

    specify 'md5_of_verbatim_collecting_event is unique within project' do
      label = "Label\nAnother line\nYet another line."
      c1    = FactoryGirl.create(:valid_collecting_event, verbatim_label: label)
      c2    = FactoryGirl.build(:valid_collecting_event, verbatim_label: label)
      expect(c2.valid?).to be_falsey
      expect(c2.errors[:md5_of_verbatim_label].count).to eq(1)
    end
  end

  context 'soft validation' do
    specify 'at least some label is provided' do
      message = 'At least one label type, or field notes, should be provided.'
      collecting_event.soft_validate
      expect(collecting_event.soft_validations.messages_on(:base).include?(message)).to be_truthy
    end
  end

  specify 'if a verbatim_label is present then a md5_of_verbatim_label is generated' do
    collecting_event.verbatim_label = "Label\nAnother line\nYet another line."
    expect(collecting_event.md5_of_verbatim_label.blank?).to be_falsey
  end

  context 'georeferences' do
    context '#generate_verbatim_georeference' do
      specify 'returns false if no verbatim values' do
        expect(collecting_event.generate_verbatim_georeference).to be_falsey
      end

      specify 'assigns a geographic item when verbatim_latitude/long are provided and !#new_record?' do
        collecting_event.verbatim_latitude  = 10
        collecting_event.verbatim_longitude = 10
        expect(collecting_event.save).to be_truthy
        expect(collecting_event.generate_verbatim_georeference).to be_truthy
        expect(collecting_event.verbatim_georeference.blank?).to be_falsey
        expect(collecting_event.verbatim_georeference.id.blank?).to be_falsey
      end
    end

    # Jim- querying across multiple columns (polygon, multi-polygon etc.) is going to be tricky,
    # we will likely need to write some sql generators to do this efficiently.  To start
    # you could just pick one column, and we can abstract out the problem later.
    context 'when the CE has a GR' do
      before(:all) {
        generate_ce_test_objects
      }
      after(:all) {
        Georeference.destroy_all
        GeographicItem.destroy_all
        CollectingEvent.destroy_all
        clean_slate_geo
      }

      context 'and that GR has some combination of GIs, and EGIs' do
        skip 'that the count of which can be found' do
          # @ce_p5 has two GRs, each of which has a GI.
          expect(@ce_p5.all_geographic_items.count).to eq(2)
          # @ce_p8 has two GRs, one of which has only a GI, and the other of which
          # has a GI, and an EGI.
          expect(@ce_p8.all_geographic_items.count).to eq(3)
          # #ce_area_v has a GR which has no GIs, nor EGIs
          expect(@ce_area_v.all_geographic_items.count).to eq(0)
        end
      end

      context 'and that GR has a GI but no EGI' do
        specify 'find other CEs that have GRs whose GI or EGI is within some radius of the source GI' do
          pieces = @ce_p7.find_others_within_radius_of(2000000)
          expect(pieces.count).to eq(8)
          expect(pieces).to include(@ce_p0, @ce_p2, @ce_p3,
                                    @ce_p5, @ce_p6, @ce_p8, @ce_p9)
          expect(pieces).not_to include(@ce_p1, @ce_p4, @ce_p7)
        end

        specify 'find other CEs that have GRs whose GI or EGI intersects the source GI' do
          pieces = @ce_p2.find_others_intersecting_with
          # @ce_p2.first will find @k and @p2
          # @k will find @p1, @p2, @p3, filter out @p2, and return @p1 and @p3
          expect(pieces.count).to eq(2)
          expect(pieces).to include(@ce_p1, @ce_p3)
          expect(pieces).not_to include(@ce_p7) # even though @p17 is close to @k
        end
      end

      context 'and that GR has both GI and EGI' do
        specify 'find other CEs that have GR whose GIs or EGIs are within some radius of the EGI' do
          pieces = @ce_p2.find_others_within_radius_of(1000000)
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
          pieces = @ce_p1.find_others_contained_in_error
          expect(pieces.count).to eq(1)
          expect(pieces.first).to eq(@ce_p2)
          expect(pieces).not_to include(@ce_p1)
        end
      end
    end
  end


  context 'associations' do
    context 'belongs_to' do
      specify 'geographic_area' do
        expect(collecting_event.geographic_area = GeographicArea.new()).to be_truthy
      end
    end
    context 'has_many' do
      specify 'collection_objects' do
        expect(collecting_event.collection_objects << CollectionObject.new).to be_truthy
      end

      specify 'georeferences' do
        expect(collecting_event.georeferences << Georeference.new).to be_truthy
      end

      specify 'geographic_items' do
        expect(collecting_event.geographic_items << GeographicItem.new).to be_truthy
      end
    end
  end

  context 'fuzzy matching' do
    before {
      @c1 = FactoryGirl.create(:valid_collecting_event, verbatim_locality: 'This is a base string.')
      @c2 = FactoryGirl.create(:valid_collecting_event, verbatim_locality: 'This is a base string.')

      @c3 = FactoryGirl.create(:valid_collecting_event, verbatim_locality: 'This is a roof string.')
      @c4 = FactoryGirl.create(:valid_collecting_event, verbatim_locality: 'This is a r00f string.')
    }

    specify 'nearest_by_levenshtein(compared_string = nil, column = "verbatim_locality", limit = 10)' do
      expect(@c1.nearest_by_levenshtein(@c1.verbatim_locality).first).to eq(@c2)
      expect(@c2.nearest_by_levenshtein(@c2.verbatim_locality).first).to eq(@c1)
      expect(@c3.nearest_by_levenshtein(@c3.verbatim_locality).first).to eq(@c4)
      expect(@c4.nearest_by_levenshtein(@c4.verbatim_locality).first).to eq(@c3)
    end
  end

  context 'geopolitical labels' do
    before(:all) {
      # create some bogus countries, states, provinces, counties, and a parish
      generate_political_areas
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

    context 'countries' do
      context 'should return hash of the country with #countries_hash' do
        context 'when one possible name is present' do
          specify 'derived from geographic_area_chain' do
            # @ce_o3 has no georeference, so the only way to 'R' is through geographic_area
            list = @ce_o3.countries_hash
            expect(list).to eq({'R' => [@area_r]})
            expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
          end
          specify 'derived from georeference -> geographic_areas chain' do
            # @ce_p4 has no geographic_area, so the only way to 'S' is through georeference
            list = @ce_p4.countries_hash
            expect(list).to eq({'S' => [@area_s]})
            expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
          end
        end

        context 'when more than one possible name is present' do
          specify 'derived from geographic_area_chain' do
            # 'Q' is synonymous with 'Big Boxia'
            # @ce_n1 has no georeference, so the only way to 'Q' is through geographic_area
            list = @ce_n1.countries_hash
            expect(list).to eq([{'Q' => [@area_q]}, {'Big Boxia' => [@area_q]}, {'Old Boxia' => [@area_ob]}])
            #  'Great Northern Land Mass' contains 'Q', and thus m1, but is NOT type 'Country'
            expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
          end
          specify 'derived from georeference -> geographic_areas chain' do
            # @ce_p1 has both geographic_area and georeference; georeference has priority
            list = @ce_p1.countries_hash
            expect(list).to eq([{'Q' => [@area_q]}, {'Big Boxia' => [@area_q]}])
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
            # @ce_p1 has a GR, and a GA.
            expect(@ce_p1.country_name).to eq('Q')
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
            expect(@ce_n2.country_name).to eq('Q')
          end
          specify 'it should return the first #countries_hash.key when an equal number of .values is present' do
            # @ce_n3 leads back to two GAs; 'R', and 'Old Boxia'
            expect(@ce_n3.country_name).to eq('R')
          end
        end
      end
    end

    context 'states' do
      context 'should return hash of the state with #states_hash' do
        context 'when one possible name is present' do
          specify 'derived from geographic_area_chain' do
            # @ce_o3 has no georeference, so the only way to 'R' is through geographic_area
            expect(@ce_o3.states_hash).to eq({'O3' => [@area_o3]})
            expect(@ce_o2.states_hash).to eq({'U' => [@area_u]})
          end
          specify 'derived from georeference -> geographic_areas chain' do
            # @ce_p4 has no geographic_area, so the only way to 'S' is through georeference
            expect(@ce_n4.states_hash).to eq({'N4' => [@area_n4]})
            expect(@ce_n2.states_hash).to eq({'T' => [@area_t]})
          end
        end

        context 'when more than one possible name is present' do
          specify 'derived from geographic_area_chain' do
            # 'T' is a state in 'Q'
            list = @ce_m1.states_hash
            expect(list).to eq({'T' => [@area_t]})
          end
          specify 'derived from georeference -> geographic_areas chain' do
            # @ce_p1 has both geographic_area and georeference; georeference has priority
            list = @ce_p1.states_hash
            expect(list).to eq({'U' => [@area_u]})
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
            # @ce_p1 has a GR, and a GA.
            expect(@ce_p1.state_name).to eq('U')
          end
          specify 'it should return the value derived from the geographic_area chain if georeference chain is not present' do
            # @ce_o3 has no GR.
            expect(@ce_o3.state_name).to eq('O3')
          end
        end

        context 'result priority' do
          specify 'it should return #countries_hash.keys.first when only one key is present' do
            # @ce_o3 leads to only one GA (named area).
            expect(@ce_o3.state_name).to eq('O3')
          end
          specify 'it should return the #countries_hash.key that has the most #countries_hash.values if more than one present' do
            # @ce_n2 leads back to three GAs; 'Q', 'Big Boxia', and 'Old Boxia'
            expect(@ce_n2.state_name).to eq('T')
          end
          specify 'it should return the first #countries_hash.key when an equal number of .values is present' do
            # @ce_n3 leads back to two GAs; 'R', and 'Old Boxia'
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
            expect(@ce_p2.counties_hash).to eq({'P2' => [@area_p2]})
          end
          specify 'derived from georeference -> geographic_areas chain' do
            # @ce_m2 has no geographic_area, so the only way to 'M2' is through georeference
            expect(@ce_m2.counties_hash).to eq({'M2' => [@area_m2]})
          end
        end

        context 'when more than one possible name is present' do
          specify 'derived from geographic_area_chain' do
            # 'Q' is synonymous with 'Big Boxia'
            list = @ce_n1.counties_hash
            expect(list).to eq([{'Q' => [@area_q]}, {'Big Boxia' => [@area_q]}, {'Old Boxia' => [@area_ob]}])
            #  'Great Northern Land Mass' contains 'Q', and thus m1, but is NOT type 'Country'
            expect(list).to_not include({'Great Northern Land Mass' => [@area_land_mass]})
          end
          specify 'derived from georeference -> geographic_areas chain' do
            # @ce_p1 has both geographic_area and georeference; georeference has priority
            list = @ce_p1.counties_hash
            expect(list).to eq([{'Q' => [@area_q]}, {'Big Boxia' => [@area_q]}])
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
            # @ce_o3 has no GR.
            expect(@ce_o3.county_name).to eq('O3')
          end
        end

        context 'result priority' do
          specify 'it should return #countries_hash.keys.first when only one key is present' do
            # @ce_o3 leads to only one GA (named area).
            expect(@ce_o3.county_name).to eq('O3')
          end
          specify 'it should return the #countries_hash.key that has the most #countries_hash.values if more than one present' do
            # @ce_n2 leads back to three GAs; 'Q', 'Big Boxia', and 'Old Boxia'
            expect(@ce_n2.county_name).to eq('N2')
          end
          specify 'it should return the first #countries_hash.key when an equal number of .values is present' do
            # @ce_n3 leads back to two GAs; 'R', and 'Old Boxia'
            expect(@ce_n3.county_name).to be_nil
          end
        end
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'notable'
    it_behaves_like 'identifiable'
  end

end
