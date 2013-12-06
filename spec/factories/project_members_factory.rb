# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_member, traits: [:creator_and_updater] do
  end
end
