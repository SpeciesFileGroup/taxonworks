FactoryBot.define do
  factory :layout_item, traits: [:housekeeping] do
    factory :valid_layout_item do
      composition { FactoryBot.create(:valid_layout) }
    end
  end
end
