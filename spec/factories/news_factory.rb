FactoryBot.define do

  factory :news, traits: [:housekeeping] do
    factory :valid_news do
      title { Faker::Lorem.unique.sentence }
      body { Faker::Lorem.unique.paragraph }
    end
  end

  factory :news_administration, parent: :valid_news, class: 'News::Administration' do
    type { 'News::Administration::Notice' }
    project_id { nil }

    transient do
      by { FactoryBot.create(:administrator) }
    end

    created_by_id { by.id }
    updated_by_id { by.id }
  end

  factory :news_project, parent: :valid_news, class: 'News::Project' do
    type { 'News::Project::Notice' }
    association :project, factory: :valid_project
  end

end
