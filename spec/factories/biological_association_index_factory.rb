FactoryBot.define do
  factory :biological_association_index, traits: [:housekeeping] do
    factory :valid_biological_association_index do
      association :biological_association, factory: :valid_biological_association
      biological_relationship { biological_association.biological_relationship }
    end
  end
end
