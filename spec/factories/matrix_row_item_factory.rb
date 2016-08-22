FactoryGirl.define do
  factory :matrix_row_item, traits: [:housekeeping] do
    factory :valid_matrix_row_item do
      association :matrix, factory: :valid_matrix
      type "MatrixRowItem::SingleOtu"
    end
  end
end
