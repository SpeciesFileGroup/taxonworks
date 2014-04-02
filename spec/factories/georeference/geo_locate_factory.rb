FactoryGirl.define do

  factory :georeference_geo_locate, class: 'Georeference::GeoLocate', traits: [:creator_and_updater] do

    factory :champaign_county do

      request {{country: 'usa', county: 'champaign', state: 'illinois', doPoly: 'true'}}

    end

    factory :valid_georeference_geo_locate, aliases: [:city_of_champaign] do

      request {{country: 'usa', locality: 'champaign', state: 'illinois', doPoly: 'true'}}

    end

    factory :city_of_urbana do

      request {{country: 'USA', locality: 'Urbana', state: 'illinois', doPoly: 'true'}}

    end

  end


end
