FactoryGirl.define do

  factory :georeference, traits: [:housekeeping] do

    factory :valid_georeference do

      association :collecting_event, factory: :valid_collecting_event, verbatim_latitude: '40.092067', verbatim_longitude: '-88.249519'
      association :geographic_item, factory: :valid_geographic_item
      type 'Georeference::VerbatimData'
    end

  end
end
