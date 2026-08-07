FactoryBot.define do
  factory :observation_matrix_row_item, traits: [:housekeeping] do
    factory :valid_observation_matrix_row_item, class: ObservationMatrixRowItem::Single do
      association :observation_matrix, factory: :valid_observation_matrix
      association :observation_object, factory: :valid_otu
      type { 'ObservationMatrixRowItem::Single' }
    end
  end
end
