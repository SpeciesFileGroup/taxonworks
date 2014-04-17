FactoryGirl.define do
  factory :project_member, traits: [:creator_and_updater] do
    factory :valid_project_member do
      association :project, factory: :valid_project
      association :user, factory: :valid_user
    end
  end
end
