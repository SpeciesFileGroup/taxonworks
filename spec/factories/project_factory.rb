FactoryBot.define do

  trait :project_valid_token do
    set_new_api_access_token { true }
  end

  factory :project, class: Project, traits: [:creator_and_updater] do
    # Don't include a name here 
    factory :valid_project do
      name { Faker::Lorem.word }
    end
  end
end
