FactoryGirl.define do
  factory :matrix_row_item, traits: [:housekeeping] do
    factory :valid_matrix_row_item, class: MatrixRowItem::SingleOtu do
      association :matrix, factory: :valid_matrix
      association :otu, factory: :valid_otu
      type "MatrixRowItem::SingleOtu"
    end
  end
end
