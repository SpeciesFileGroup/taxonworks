FactoryBot.define do
  factory :identifier_local_record_number, class: 'Identifier::Local::RecordNumber', traits: [:housekeeping] do
    factory :valid_identifier_local_record_number do
      identifier { Faker::Lorem.unique.word }
      #association :identifier_object, factory: :valid_specimen, strategy: :build
      association :namespace, factory: :valid_namespace
    end
  end
end
