require 'rails_helper'

describe Georeference::VerbatimData, type: :model, group: :geo do
  context 'VerbatimData uses self.collecting_event to internalize data' do
    specify 'without elevation' do
      georeference = Georeference::VerbatimData.new(collecting_event: FactoryGirl.build(:valid_collecting_event,
                                                                                        verbatim_latitude:  "n40º5'31.4412\"",
                                                                                        verbatim_longitude: 'w88∫11′43.3″'))
      expect(georeference.is_median_z).to be_falsey
      expect(georeference.is_undefined_z).to be_truthy
      expect(georeference.save).to be_truthy
      expect(georeference.geographic_item.geo_object.to_s).to eq('POINT (-88.195361 40.092067 735.0)')
    end

    specify 'with *only* minimum elevation' do
      georeference = Georeference::VerbatimData.new(collecting_event: FactoryGirl.build(:valid_collecting_event,
                                                                                        minimum_elevation:  759,
                                                                                        verbatim_latitude:  '40.092067',
                                                                                        verbatim_longitude: '-88.249519'))
      expect(georeference.is_median_z).to be_falsey
      expect(georeference.is_undefined_z).to be_falsey
      expect(georeference.save).to be_truthy
      expect(georeference.geographic_item.geo_object.to_s).to eq('POINT (-88.249519 40.092067 735.0)')
    end

    specify 'with minimum and maximim elevation' do
      georeference = Georeference::VerbatimData.new(collecting_event: FactoryGirl.build(:valid_collecting_event,
                                                                                        minimum_elevation:  759,
                                                                                        maximum_elevation:  859,
                                                                                        verbatim_latitude:  '40.092067',
                                                                                        verbatim_longitude: '-88.249519'))
      expect(georeference.is_median_z).to be_truthy
      expect(georeference.is_undefined_z).to be_falsey
      expect(georeference.save).to be_truthy
      expect(georeference.geographic_item.geo_object.to_s).to eq('POINT (-88.249519 40.092067 735.0)')
    end
  end

end
