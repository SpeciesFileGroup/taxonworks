FactoryGirl.define do
  factory :matrix_column, traits: [:housekeeping] do
    factory :valid_matrix_column do
      association :matrix, factory: :valid_matrix
      association :descriptor, factory: :valid_descriptor
    end
  end
end

