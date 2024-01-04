FactoryBot.define do
  factory :taxon_determination, traits: [:housekeeping] do
    association :otu, factory: :valid_otu
    factory :valid_taxon_determination do
      association :taxon_determination_object, factory: :valid_specimen
      # !! association :determiner, factory: :valid_determiner needs to be built
    end 
  end
end
