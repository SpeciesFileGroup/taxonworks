FactoryGirl.define do

  factory :combination, traits: [:housekeeping] do
    type 'Combination'
    name nil

    # TODO Does not work. To make it work, a Protonym (a parent) should be created and saved,
    # Combination created and saved. After that relationships could be added 
    # could use build_stubbed perhaps
    factory :subgenus_combination do
      type 'Combination'
      association :genus, factory: :relationship_genus, name: 'Aus'
      association :subgenus, factory: :relationship_genus, name: 'Bus'
      association :parent, factory: :relationship_genus, name: 'Bus'
    end

    # Does not work. Same problem as above.
    factory :species_combination do
      type 'Combination'
      association :genus, factory: :relationship_genus, name: 'Aus' 
      association :species, factory: :relationship_species, name: 'bus'
      association :parent, factory: :relationship_species, name: 'bus'
    end
  end
end
