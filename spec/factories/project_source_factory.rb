FactoryGirl.define do
  factory :project_source do
    factory :valid_project_source,  traits: [:housekeeping] do
      association :project, factory: :valid_project
      association :source, factory: :valid_source
    end
  end
end
