FactoryGirl.define do

  factory :chresonym, class: Chresonym do
    type 'Chresonym'
    name nil
  end

  factory :subgenus_chresonym, class: Chresonym do
    type 'Chresonym'
    name nil
    association :genus, factory: :iczn_genus, name: "Aus"
    association :subgenus, factory: :iczn_genus, name: "Bus"
  end

  factory :species_chresonym, class: Chresonym do
    type 'Chresonym'
    name nil
    association :genus, factory: :iczn_genus, name: "Aus"
    association :species, factory: :iczn_species, name: 'bus'
  end

end
