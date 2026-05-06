FactoryBot.define do
  factory :georeference_gazetteer, class: 'Georeference::Gazetteer', traits: [:housekeeping] do
    association :collecting_event, factory: :valid_collecting_event

    transient do
      gazetteer_record { association(:valid_gazetteer) }
    end

    gazetteer_id { gazetteer_record.id }
    geographic_item { gazetteer_record.geographic_item }
    type { 'Georeference::Gazetteer' }

    factory :valid_georeference_gazetteer
  end
end
