FactoryBot.define do
  factory :layout_item_group_item, class: LayoutItem::GroupItem, traits: [:housekeeping] do
    factory :valid_layout_item_group_item do
      composition { FactoryBot.create(:valid_layout) }
    end
  end
end
