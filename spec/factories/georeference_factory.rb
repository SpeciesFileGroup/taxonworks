FactoryBot.define do

  factory :georeference, traits: [:housekeeping] do
    factory :valid_georeference, aliases: [:valid_georeference_with_point_a] do
      association :collecting_event, factory: :valid_collecting_event  # :collecting_event_my_office
      association :geographic_item, factory: :valid_geographic_item    # :geographic_item_with_point_a
      type { 'Georeference::VerbatimData' }
    end

    factory :georeference_from_verbatim do
      type { 'Georeference::VerbatimData' }
    end

    factory :georeference_from_geo_locate do
      type { 'Georeference::GeoLocate' }
    end

    factory :georeference_from_google_map do
      type { 'Georeference::GoogleMap' }
    end

  end
end
