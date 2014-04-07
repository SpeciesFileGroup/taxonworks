require 'spec_helper'

describe Georeference::VerbatimData do
  context 'VerbatimData uses self.collecting_event to internalize data' do

    specify 'without elevation' do
      #pending "without elevation"
      georeference = Georeference::VerbatimData.new(collecting_event: FactoryGirl.build(:valid_collecting_event,
                                                                                        verbatim_latitude:  '40.092067',
                                                                                        verbatim_longitude: '-88.249519'))
      #georeference = FactoryGirl.build(:valid_georeference_verbatim_data)
      expect(georeference.is_median_z).to be_false
      expect(georeference.is_undefined_z).to be_true
      expect(georeference.geographic_item.geo_object).to eq('point(-88.249519 40.092067 0.0)')
    end

    specify 'with *only* minimum elevation' do
      pending "with only minimum elevation"
      georeference = Georeference::VerbatimData.new(collecting_event: FactoryGirl.build(:valid_collecting_event,
                                                                                        minimum_elevation: 759,
                                                                                        verbatim_latitude:  '40.092067',
                                                                                        verbatim_longitude: '-88.249519'))
      #georeference = FactoryGirl.build(:valid_georeference_verbatim_data)
      expect(georeference.is_median_z).to be_false
      expect(georeference.is_undefined_z).to be_false
      expect(georeference.geographic_item.geo_object).to eq('point(-88.249519 40.092067 759.0)')
    end

    specify 'with minimum and maximim elevation' do
      pending "with minimum elevation and maximim elevation"
      georeference = Georeference::VerbatimData.new(collecting_event: FactoryGirl.build(:valid_collecting_event,
                                                                                        minimum_elevation: 759,
                                                                                        maximum_elevation: 859,
                                                                                        verbatim_latitude:  '40.092067',
                                                                                        verbatim_longitude: '-88.249519'))
      #georeference = FactoryGirl.build(:valid_georeference_verbatim_data)
      expect(georeference.is_median_z).to be_true
      expect(georeference.is_undefined_z).to be_false
      expect(georeference.geographic_item.geo_object).to eq('point(-88.249519 40.092067 809.0)')
    end

  end

end
