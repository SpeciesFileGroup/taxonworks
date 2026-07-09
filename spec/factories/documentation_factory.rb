FactoryBot.define do
  factory :documentation, class: Documentation, traits: [:creator_and_updater] do
    factory :valid_documentation do
      association :documentation_object, factory: :valid_collecting_event
      after(:build) do |documentation|
        FactoryProjectHelpers.assign_project_scoped(documentation, :document, :valid_document)
      end
    end
  end
end

