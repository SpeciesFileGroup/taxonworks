FactoryBot.define do
  factory :identifier_local_event, class: 'Identifier::Local::Event', traits: [:housekeeping] do
    factory :valid_identifier_local_event do
      identifier { Faker::Lorem.unique.word }
      #association :identifier_object, factory: :valid_collecting_event, strategy: :build
      association :namespace, factory: :valid_namespace
    end
  end
end

