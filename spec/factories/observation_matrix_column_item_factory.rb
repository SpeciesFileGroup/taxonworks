FactoryBot.define do
  factory :observation_matrix_column_item, traits: [:housekeeping] do
    factory :valid_observation_matrix_column_item, class: ObservationMatrixColumnItem::SingleDescriptor do
      association :observation_matrix, factory: :valid_observation_matrix
      association :descriptor, factory: :valid_descriptor
      type 'ObservationMatrixColumnItem::SingleDescriptor'
    end
  end
end
