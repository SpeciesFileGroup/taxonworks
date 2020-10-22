FactoryBot.define do

  trait :project_valid_token do
    set_new_api_access_token { true }
  end

  factory :project, class: Project, traits: [:creator_and_updater] do
    # Don't include a name here 
    factory :valid_project do
      name { Faker::Lorem.sentence(word_count: 3, supplemental: false, random_words_to_add: 4) }
    end
  end
end
