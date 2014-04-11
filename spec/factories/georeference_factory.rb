FactoryGirl.define do

  factory :georeference, traits: [:housekeeping] do

    factory :valid_georeference, aliases: [:valid_georeference_with_point_a] do

      association :collecting_event, factory: :collecting_event_my_office
      association :geographic_item, factory: :geographic_item_with_point_a

    end

    factory :georeference_from_verbatim do

    end

    factory :georeference_from_geo_locate do

    end

  end
end
