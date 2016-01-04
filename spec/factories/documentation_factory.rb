FactoryGirl.define do
  factory :documentation, class: Documentation, traits: [:creator_and_updater] do
    factory :valid_documentation do
      association :document, factory: :valid_document
      association :documentation_object, factory: :valid_collecting_event
      type 'Documentation::CollectingEventDocumentation'
    end
  end
end

