FactoryBot.define do
  factory :field_occurrence, traits: [:housekeeping] do
    factory :valid_field_occurrence do
      total { 1 }
      association :collecting_event, factory: :valid_collecting_event
      is_absent { false }
      association :taxon_determinations, factory: :taxon_determination
    end
  end
end
