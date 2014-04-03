FactoryGirl.define do

  factory :georeference, traits: [:creator_and_updater] do

    factory :valid_georeference do
      association :collecting_event, factory: :valid_collecting_event
      association :geographic_itme, factory: :valid_geographic_item
      type 'Georeference::VerbatimData'
    end

    factory :point_georeference do

    end


    # This goes in /georeference/verbatim_data_factory.rb
    factory :georeference_verbatim_data, class: 'Georeference::VerbatimData', traits: [:houskeeping] do
      factory :valid_georeference_verbatim_data do
        association :collecting_event, factory: :valid_collecting_event, verbatim_latitude: '23.2323', verbatim_longitude: '23.23232'
        association :geographic_itme, factory: :balid_geographic_item
        # type 'Georeference::VerbatimData'
         
      end

    # identical in geolocate
    # should also have api_request

    end

  end

end
