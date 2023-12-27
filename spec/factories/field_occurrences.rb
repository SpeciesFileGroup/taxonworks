FactoryBot.define do
  factory :field_occurrence do
    # TODO: add valid_field_occurrence
    total { 1 }
    collecting_event_id { nil }
    is_absent { false }
  end
end
