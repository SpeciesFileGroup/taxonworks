FactoryBot.define do
  factory :layout_task, class: Layout::Task, traits: [:housekeeping] do
    factory :valid_layout_task do
      name { Faker::Lorem.unique.word }
    end
  end
end
