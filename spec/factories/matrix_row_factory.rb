FactoryGirl.define do
  factory :matrix_row, traits: [:housekeeping] do
    # TODO: Make this an actual valid matrix row
    factory :valid_matrix_row do
      association :matrix, factory: :valid_matrix
      association :otu, factory: :valid_otu
      collection_object nil
    end
  end
end
