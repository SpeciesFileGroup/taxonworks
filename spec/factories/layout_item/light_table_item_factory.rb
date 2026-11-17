FactoryBot.define do
  factory :layout_item_light_table_item, class: LayoutItem::LightTableItem, traits: [:housekeeping] do
    factory :valid_layout_item_light_table_item do
      composition { FactoryBot.create(:valid_layout_light_table) }
      composition_item_object { FactoryBot.create(:valid_depiction) }
    end
  end
end
