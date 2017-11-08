FactoryBot.define do
  factory :otu, traits: [:housekeeping] do
    factory :valid_otu do
      name { Faker::Lorem.word }
    end
    factory :valid_otu_with_taxon_name do
      name { Faker::Lorem.word }
      association :taxon_name, factory: :relationship_species
    end
  end
end
