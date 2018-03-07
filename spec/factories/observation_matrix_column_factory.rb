FactoryBot.define do
  factory :observation_matrix_column, traits: [:housekeeping] do
    factory :valid_observation_matrix_column do
      association :observation_matrix, factory: :valid_observation_matrix
      association :descriptor, factory: :valid_descriptor
    end
  end
end

