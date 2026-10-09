FactoryBot.define do
  factory :layout_item_image_item, class: LayoutItem::ImageItem, traits: [:housekeeping] do
    factory :valid_layout_item_image_item do
      composition { FactoryBot.create(:valid_layout) }
      composition_item_object { FactoryBot.create(:valid_image) }
    end
  end
end
