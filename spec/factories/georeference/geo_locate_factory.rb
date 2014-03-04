FactoryGirl.define do

  factory :georeference_geo_locate, class: 'Georeference::GeoLocate', traits: [:creator_and_updater] do

    factory :valid_georeference_geo_locate do

      request {{country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true'}}

    end

  end


end
