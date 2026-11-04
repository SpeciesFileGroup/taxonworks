FactoryBot.define do
  factory :composition_item, traits: [:housekeeping] do
    factory :valid_composition_item do
      type { 'LayoutItem' }
      composition { FactoryBot.create(:valid_layout) }
    end

    initialize_with { new(type: type) }
  end
end
