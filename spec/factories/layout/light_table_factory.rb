FactoryBot.define do
  factory :layout_light_table, class: Layout::LightTable, traits: [:housekeeping] do
    factory :valid_layout_light_table do
      name { Faker::Lorem.unique.word }
    end
  end
end
