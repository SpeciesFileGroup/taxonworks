FactoryGirl.define do

  factory :georeference, traits: [:housekeeping] do

    factory :valid_georeference, aliases: [:valid_georeference_with_point_a] do

      association :collecting_event, factory: :collecting_event_my_office
      association :geographic_item, factory: :geographic_item_with_point_a

      type  'Georeference::Unknown'

    end

    factory :georeference_from_verbatim do
      type  'Georeference::VerbatimData'

    end

    factory :georeference_from_geo_locate do
      type  'Georeference::GeoLocate'

    end

  end
end
