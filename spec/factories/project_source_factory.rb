# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_source, traits: [:creator_and_updater] do
    factory :valid_project_source do
      association :project, factory: :valid_project
      association :source, factory: :valid_source
    end
  end
end
