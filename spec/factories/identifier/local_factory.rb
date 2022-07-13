FactoryBot.define do
  factory :identifier_local, class: 'Identifier::Local', traits: [:housekeeping] do
    factory :valid_identifier_local, class: 'Identifier::Local', traits: [:housekeeping] do
      association :namespace, factory: :valid_namespace
      association :identifier_object, factory: :valid_otu
      identifier { 123 }
    end
  end
end
