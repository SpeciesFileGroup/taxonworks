FactoryBot.define do
  factory :combination, traits: [:housekeeping] do
    type { 'Combination' }
    name { nil }
  end

  factory :valid_combination, parent: :combination do
    transient do
      genus_name   { 'Aus' }
      species_name { 'bus' }
    end

    # Persist only after we have attached the protonyms (so validations pass).
    to_create do |c, evaluator|
      genus = FactoryBot.create(:relationship_genus, name: evaluator.genus_name)
      species = FactoryBot.create(:relationship_species, parent: genus, name: evaluator.species_name)

      c.genus = genus
      c.species = species

      c.save!
    end
  end

  factory :valid_species_combination, parent: :valid_combination

  factory :valid_subgenus_combination, parent: :combination do
    transient do
      genus_name    { 'Aus' }
      subgenus_name { 'Bus' }
    end

    to_create do |c, evaluator|
      genus = FactoryBot.create(:relationship_genus, name: evaluator.genus_name)
      subgenus = FactoryBot.create(:iczn_subgenus, parent: genus, name: evaluator.subgenus_name)

      c.genus = genus
      c.subgenus = subgenus

      c.save!
    end
  end
end
