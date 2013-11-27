FactoryGirl.define do

  factory :combination, class: Combination do
    type 'Combination'
    name nil
  end

  # Does not work. To make it work, a Protonym (a parent) should be created and saved,
  # Combination created and saved. After that relationships could be added
  factory :subgenus_combination, class: Combination do
    type 'Combination'
    name nil
    association :genus, factory: :relationship_genus, name: 'Aus'
    association :subgenus, factory: :relationship_genus, name: 'Bus'
    association :parent, factory: :relationship_genus, name: 'Bus'
  end

  # Does not work. Same problem as above.
  factory :species_combination, class: Combination do
    type 'Combination'
    name nil
    association :genus, factory: :relationship_genus, name: 'Aus'
    association :species, factory: :relationship_species, name: 'bus'
    association :parent, factory: :relationship_species, name: 'bus'
  end

end
