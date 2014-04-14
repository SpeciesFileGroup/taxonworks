FactoryGirl.define do

  factory :georeference_verbatim_data, class: 'Georeference::VerbatimData', traits: [:housekeeping] do

    factory :valid_georeference_verbatim_data,  aliases: [:my_office] do

      # valid_collecting_event needs valid lat/long data to be a proper object for verbatim_data
      association :collecting_event, factory: :collecting_event_my_office

      association :geographic_item, factory: :valid_geographic_item

      error_radius 16000


    end

  end

end
