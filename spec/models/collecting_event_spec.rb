require 'spec_helper'

describe CollectingEvent do
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

    specify 'end date is > start date' do
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
    end
  end

  context 'concerns' do
    it_behaves_like 'citable'
    it_behaves_like 'notable'
    it_behaves_like 'identifiable'
  end

end
