FactoryBot.define do
  factory :field_occurrence, traits: [:housekeeping] do
    factory :valid_field_occurrence do
      total { 1 }
      association :collecting_event, factory: :valid_collecting_event
      association :taxon_determination, factory: :valid_taxon_determination
      is_absent { false }
    end
  end
end
