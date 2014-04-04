FactoryGirl.define do

  factory :georeference_verbatim_data, class: 'Georeference::VerbatimData', traits: [:housekeeping] do

    factory :valid_georeference_verbatim_data do

      # valid_collecting_event needs valid lat/long data to be a proper object for verbatim_data
      association :collecting_event,
                  factory: :valid_collecting_event,
                  minimum_elevation: 795,
                  verbatim_latitude: '40.092067',
                  verbatim_longitude: '-88.249519'
      association :geographic_item, factory: :valid_geographic_item
      association :error_geographic_item, factory: :geographic_item_with_polygon

      error_radius 3.0


    end

  end

end
