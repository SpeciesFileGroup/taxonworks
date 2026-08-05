require 'rails_helper'

describe Georeference::VerbatimData, type: :model, group: [:geo, :georeferences] do

  let(:c) { CollectingEvent.create!(
    verbatim_latitude: 1.1234,
    verbatim_longitude: 5.6789,
  )}

  let(:g) { Georeference::VerbatimData.new(collecting_event: c) }

  specify 'requires minimal collecting event' do
    expect{Georeference::VerbatimData.create!(collecting_event: c)}.to_not raise_error
  end

  specify '#error_radius 1' do
    c.update!(verbatim_geolocation_uncertainty: '4 m')
    h = Georeference::VerbatimData.create!(collecting_event: c)
    expect(h.error_radius).to eq(4)
  end

  specify '#error_radius 2' do
    c.update!(verbatim_geolocation_uncertainty: '4 ft')
    h = Georeference::VerbatimData.create!(collecting_event: c)
    expect(h.error_radius).to eq(1) # Rounds to 1 meter
  end

  specify '#error_radius 3' do
    c.update!(verbatim_geolocation_uncertainty: '4 kahugeflugers')
    h = Georeference::VerbatimData.create!(collecting_event: c)
    expect(h.error_radius).to eq(nil)
  end

  specify 'encoding 1' do
    c.update!(verbatim_latitude: "n40º5'31.4412\"",
              verbatim_longitude: 'w88∫11′43.3″')
    expect{Georeference::VerbatimData.create!(collecting_event: c)}.to_not raise_error
  end

  specify '#geo_object' do
    expect(g.geographic_item.geo_object.to_s).to eq('POINT (5.6789 1.1234 0.0)')
  end

  specify 'with *only* minimum elevation' do
    c.update!(minimum_elevation: 759)
    h = Georeference::VerbatimData.create!(collecting_event: c)
    expect(h.geographic_item.geo_object.to_s).to eq('POINT (5.6789 1.1234 759.0)')
  end

  specify 'with minimum and maximim elevation' do
    georeference = Georeference::VerbatimData.new(collecting_event: FactoryBot
      .build(:valid_collecting_event,
             minimum_elevation: 759,
             maximum_elevation: 859,
             verbatim_elevation: nil,
             verbatim_latitude: '40.092067',
             verbatim_longitude: '-88.249519'))
    expect(georeference.save).to be_truthy
    expect(georeference.geographic_item.geo_object.to_s).to eq('POINT (-88.249519 40.092067 809.0)')
  end

  context 'destroying a georeference whose geographic_item is orphaned' do
    let(:georef) {
      Georeference::VerbatimData.create!(collecting_event: c)
    }

    specify 'destroying the georeference directly does not raise' do
      expect { georef.destroy! }.not_to raise_error
    end

    specify 'destroying the collecting_event (cascade) does not raise' do
      georef
      expect { c.destroy! }.not_to raise_error
    end

    specify 'collecting_event cached geographic names are updated after destroy' do
      georef
      expect(c.geographic_name_classification_method).to be(:preferred_georeference)
      c.destroy!
      expect(c.geographic_name_classification_method).to_not be(:preferred_georeference)
    end
  end

  context 'when a second georeference remains after the preferred is destroyed' do
    let(:georef2) { FactoryBot.create(:valid_georeference, collecting_event: c) }
    let(:georef1) { Georeference::VerbatimData.create!(collecting_event: c) }

    before do
      georef2  # position 1 initially
      georef1  # acts_as_list adds at top: becomes position 1, georef2 shifts to 2
    end

    specify 'geographic_name_classification_method returns :preferred_georeference' do
      georef1.destroy!
      expect(c.reload.send(:geographic_name_classification_method)).to eq(:preferred_georeference)
    end

    specify 'the remaining georeference becomes preferred' do
      georef1.destroy!
      expect(c.reload.preferred_georeference.id).to eq(georef2.id)
    end
  end

  specify 'two georeferences might use the same geographic_item' do
    georeference1 = Georeference::VerbatimData.new(collecting_event: FactoryBot
      .build(:valid_collecting_event,
             minimum_elevation: 759,
             maximum_elevation: 859,
             verbatim_elevation: nil,
             verbatim_latitude: '40.092067',
             verbatim_longitude: '-88.249519'))

    # save this record to propagate the geographic_item so that second georeference can find it.
    expect(georeference1.save).to be_truthy
    georeference2 = Georeference::VerbatimData.new(collecting_event: FactoryBot
      .build(:valid_collecting_event,
             minimum_elevation: 759,
             maximum_elevation: 859,
             verbatim_elevation: nil,
             verbatim_latitude: '40.092067',
             verbatim_longitude: '-88.249519'))

    expect(georeference1.save).to be_truthy
    expect(georeference2.save).to be_truthy
    expect(georeference1.geographic_item.id).to eq(georeference2.geographic_item.id)
  end
end

