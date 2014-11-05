FactoryGirl.define do
  factory :type_material, traits: [:housekeeping] do

    factory :valid_type_material do
      type_type 'holotype'
      association :protonym, factory: :iczn_species
      association :material, factory: :valid_specimen
    end

    factory :new_valid_type_material do
      type_type 'lectotype'
      association :protonym, factory: :iczn_species
      association :material, factory: :valid_specimen
    end

    factory :invalid_type_material do
      type_type 'invalid'
      association :protonym, factory: :iczn_species
      association :material, factory: :valid_specimen
    end
  end
end

