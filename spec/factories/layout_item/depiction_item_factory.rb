FactoryBot.define do
  factory :layout_item_depiction_item, class: LayoutItem::DepictionItem, traits: [:housekeeping] do
    factory :valid_layout_item_depiction_item do
      composition { FactoryBot.create(:valid_layout) }
      composition_item_object { FactoryBot.create(:valid_depiction) }
    end
  end
end
