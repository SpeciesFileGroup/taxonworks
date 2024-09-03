FactoryBot.define do
  factory :identifier_local_catalog_number, class: Identifier::Local::CatalogNumber, traits: [:housekeeping] do
    factory :valid_identifier_local_catalog_number  do
      association :namespace, factory: :valid_namespace
      identifier { '12345' }
      association :identifier_object, factory: :valid_specimen, strategy: :build
    end
  end
end
