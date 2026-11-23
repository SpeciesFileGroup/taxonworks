FactoryBot.define do
  factory :layout_item_task_item, class: LayoutItem::TaskItem, traits: [:housekeeping] do
    factory :valid_layout_item_task_item do
      composition { FactoryBot.create(:valid_layout_task) }
      composition_item_object { FactoryBot.create(:valid_collection_object) }
    end
  end
end
