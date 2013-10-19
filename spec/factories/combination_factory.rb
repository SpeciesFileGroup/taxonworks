FactoryGirl.define do

  factory :combination, class: Combination do
    type 'Combination'
    name nil
  end

  factory :subgenus_combination, class: Combination do
    type 'Combination'
    name nil
    association :genus, factory: :iczn_genus, name: "Aus"
    association :subgenus, factory: :iczn_genus, name: "Bus"
  end

  factory :species_combination, class: Combination do
    type 'Combination'
    name nil
    association :genus, factory: :iczn_genus, name: "Aus"
    association :species, factory: :iczn_species, name: 'bus'
  end

end
