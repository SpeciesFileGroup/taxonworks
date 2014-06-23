require 'spec_helper'

describe CollectingEvent do
  before(:all) {
    # generate_geo_test_objects
  }
  let(:collecting_event) { FactoryGirl.build(:collecting_event) }

  context 'validation' do
    specify 'if verbatim_geolocation_uncertainty is provided, then so to are verbatim_longitude and verbatim_latitude' do
      collecting_event.verbatim_geolocation_uncertainty = 'based on my astrolab'
      expect(collecting_event.valid?).to be_false
      expect(collecting_event.errors.include?(:verbatim_geolocation_uncertainty)).to be_true
    end

    specify 'corresponding verbatim_latitude value is provide' do
      collecting_event.verbatim_latitude = '12.345'
      expect(collecting_event.valid?).to be_false
      expect(collecting_event.errors.include?(:verbatim_longitude)).to be_true
    end

    specify 'corresponding verbatim_longitude value is provide' do
      collecting_event.verbatim_longitude = '12.345'
      expect(collecting_event.valid?).to be_false
      expect(collecting_event.errors.include?(:verbatim_latitude)).to be_true
    end

    specify 'start_date_year is valid as 4 digit integer' do
      # You can also pass a string, casting is automatic
      collecting_event.start_date_year = 1942
      collecting_event.valid?
      expect(collecting_event.errors_on(:start_date_year)).to eq([])
    end

    specify 'start_date_year is invalid as 3 digit integer' do
      collecting_event.start_date_year = '194'
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_year)).to be_true 
    end

    specify 'start_date_year is invalid as when > 5 years from the future' do
      collecting_event.start_date_year = (Time.now.year + 6)
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_year)).to be_true
    end

    specify 'start_date_year is invalid when less than 1000' do
      collecting_event.start_date_year = 999 
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_year)).to be_true 
    end

    specify 'end_date_year is valid as 4 digit integer' do
      # You can also pass a string, casting is automatic
      collecting_event.end_date_year = 1942
      collecting_event.valid?
      expect(collecting_event.errors_on(:end_date_year)).to eq([])
    end

    specify 'end_date_year is invalid as 3 digit integer' do
      collecting_event.end_date_year = '194'
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_year)).to be_true 
    end

    specify 'end_date_year is invalid as when > 5 years from the future' do
      collecting_event.end_date_year = Time.now.year + 6 
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_year)).to be_true 
    end

    specify 'end_date_year is invalid when less than 1000' do
      collecting_event.end_date_year = 999 
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_year)).to be_true 
    end

    specify 'start_date_month is invalid when not included in LEGAL_MONTHS' do
      ['ab', :jani, 'Febuary', 13, 0].each do |m|
        collecting_event.start_date_month = m
        collecting_event.valid?
        expect(collecting_event.errors.include?(:start_date_month)).to be_true 
      end
    end

    specify 'start_date_day is invalid when not an integer' do
      collecting_event.start_date_day = "a"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_day)).to be_false
    end

    specify 'start_date_day is value bound by month' do
      collecting_event.start_date_year = "1945" # requires year for leaps
      collecting_event.start_date_month = "2"
      collecting_event.start_date_day = "30"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_day)).to be_true
    end

    specify 'start_date_month is invalid when nil AND start_date_day provided' do
      collecting_event.start_date_day = 1 
      collecting_event.valid?
      expect(collecting_event.errors.include?(:start_date_month)).to be_true
    end

    specify 'end_date_month is invalid when not included in LEGAL_MONTHS' do
      ['ab', :jani, 'Febuary', 13, 0].each do |m|
        collecting_event.end_date_month = m
        collecting_event.valid?
        expect(collecting_event.errors.include?(:end_date_month)).to be_true 
      end
    end

    specify 'end_date_day is invalid when not an integer' do
      collecting_event.end_date_day = "a"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_day)).to be_false
    end

    specify 'end_date_day is value bound by month' do
      collecting_event.end_date_year = "1945" # requires year for leaps
      collecting_event.end_date_month = "2"
      collecting_event.end_date_day = "30"
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_day)).to be_true
    end

    specify 'end_date_month is invalid when nil AND end_date_day provided' do
      collecting_event.end_date_day = 1 
      collecting_event.valid?
      expect(collecting_event.errors.include?(:end_date_month)).to be_true
    end

    specify 'end date is > start date when both are provided' do
      message = 'End date is earlier than start date.'   
      collecting_event.start_date_day = 2
      collecting_event.start_date_month = 1
      collecting_event.start_date_year = 1

      collecting_event.end_date_day = 1
      collecting_event.end_date_month = 1
      collecting_event.end_date_year = 1

      expect(collecting_event.valid?).to_not be_true 
      expect(collecting_event.errors_on(:base).include?(message)).to be_true
    end 

    specify 'maximum elevation is greater than minimum elevation when both provided' do
      message = 'Maximum elevation is lower than minimum elevation.'
      collecting_event.minimum_elevation = 2
      collecting_event.maximum_elevation = 1
      expect(collecting_event.valid?).to_not be_true 
      expect(collecting_event.errors_on(:maximum_elevation).include?(message)).to be_true
    end

    specify 'md5_of_verbatim_collecting_event is unique within project' do
      label =  "Label\nAnother line\nYet another line." 
      c1 = FactoryGirl.create(:valid_collecting_event, verbatim_label: label)
      c2 = FactoryGirl.build(:valid_collecting_event, verbatim_label: label)
      expect(c2.valid?).to be_false
      expect(c2.errors_on(:md5_of_verbatim_label)).to have(1).things
    end
 end

  context 'soft validation' do
    specify 'at least some label is provided' do
      message = 'At least one label type, or field notes, should be provided.'   
      collecting_event.soft_validate
      expect(collecting_event.soft_validations.messages_on(:base).include?(message)).to be_true
    end
  end

  specify 'if a verbatim_label is present then a md5_of_verbatim_label is generated' do
    collecting_event.verbatim_label = "Label\nAnother line\nYet another line."
    expect(collecting_event.md5_of_verbatim_label.blank?).to be_false
  end

  context 'georeferences' do
    context '#generate_verbatim_georeference' do
      specify 'returns false if no verbatim values' do
        expect(collecting_event.generate_verbatim_georeference).to be_false
      end 

      specify 'assigns a geographic item when verbatim_latitude/long are provided and !#new_record?' do
        collecting_event.verbatim_latitude = 10
        collecting_event.verbatim_longitude = 10
        expect(collecting_event.save).to be_true
        expect(collecting_event.generate_verbatim_georeference).to be_true
        expect(collecting_event.verbatim_georeference.blank?).to be_false
        expect(collecting_event.verbatim_georeference.id.blank?).to be_false
      end
    end

    # Jim- querying across multiple columns (polygon, multi-polygon etc.) is going to be tricky,
    # we will likely need to write some sql generators to do this efficiently.  To start
    # you could just pick one column, and we can abstract out the problem later.
    context 'when the CE has a georeference' do
      before(:all) {
        generate_ce_test_objects
      }
      after(:all){
        clean_slate_geo
      }
      context 'and that georeference has a geographic_item but NO no error_geographic_item' do

        specify 'find other CEs that have georeferences whose GI or EGI is within some radius of the source GI' do
          expect(@ce_p0.georeferences.count).to eq(2)
          expect(@ce_p0.georeferences.first.geographic_item)
        end

        skip 'find other CES that have georeferences whose GI or EGI intersects the source GI' 
      end

      context 'and that georeference has both geographic item and error_geographic_item' do

        specify 'find other CEs that have georeferences whose GIs or EGIs are within some radius of the EGI' do
          skip 
        end
        specify 'find other CEs that have georeferences whose GIs or EGIs are are contained in the EGI' do
          skip 
        end
      end
    end
  end


  context 'associations' do
    context 'belongs_to' do
      specify 'geographic_area' do
        expect(collecting_event.geographic_area = GeographicArea.new()).to be_true 
      end
    end
    context 'has_many' do
      specify 'collection_objects' do
        expect(collecting_event.collection_objects << CollectionObject.new).to be_true 
      end

      specify 'georeferences' do
        expect(collecting_event.georeferences << Georeference.new).to be_true 
      end

      specify 'geographic_items' do
        expect(collecting_event.geographic_items << GeographicItem.new).to be_true 
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'notable'
    it_behaves_like 'identifiable'
  end

end
