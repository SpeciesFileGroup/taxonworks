FactoryBot.define do
  factory :project_organization, traits: [:housekeeping] do
    factory :valid_project_organization do
      association :organization, factory: :valid_organization
    end
  end
end
