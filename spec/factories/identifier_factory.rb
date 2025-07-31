FactoryBot.define do
  factory :identifier, traits: [:housekeeping] do
    factory :valid_identifier, class: 'Identifier::Local::CatalogNumber' do
      association :identifier_object, factory: :valid_specimen
      identifier { Faker::Lorem.unique.word }
      association :namespace, factory: :valid_namespace
    end
  end

end
