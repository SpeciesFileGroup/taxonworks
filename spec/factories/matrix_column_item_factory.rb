FactoryGirl.define do
  factory :matrix_column_item, traits: [:housekeeping] do
    factory :valid_matrix_column_item, class: MatrixColumnItem::SingleDescriptor do
      association :matrix, factory: :valid_matrix
      association :descriptor, factory: :valid_descriptor
      type 'MatrixColumnItem::SingleDescriptor'
    end
  end
end
