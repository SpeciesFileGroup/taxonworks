FactoryBot.define do
  factory :identifier_local_field_number, class: 'Identifier::Local::FieldNumber', traits: [:housekeeping] do
    factory :valid_identifier_local_field_number do
      identifier {'12345'}
      association :identifier_object, factory: :valid_collecting_event, strategy: :build
      association :namespace, factory: :valid_namespace
    end
  end
end
