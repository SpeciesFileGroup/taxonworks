FactoryGirl.define do
  factory :matrix_column_item_descriptor, traits: [:housekeeping] do
    factory :valid_matrix_column_item_descriptor do
      association :matrix, factory: :valid_matrix
      association :descriptor, factory: :valid_descriptor
      type 'MatrixColumnItem::Descriptor'
    end
  end
end
