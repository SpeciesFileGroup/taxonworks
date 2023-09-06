FactoryBot.define do
  factory :role, traits: [:creator_and_updater] do
    factory :valid_role do
      type { 'SourceAuthor' }
      association :person, factory: :valid_person
      association :role_object, factory: :valid_source_bibtex
    end

    # This is a stub for Project warning/specs
    factory :valid_project_role do
      type { 'Collector' } 
      association :person, factory: :valid_person
      association :role_object, factory: :valid_collecting_event
    end

    # This is a stub for Project warning/specs
    factory :valid_attribution_role do
      type { 'Creator' } 
      association :person, factory: :valid_person
      association :role_object, factory: :valid_content
    end

    factory :valid_collector do
      type { 'Collector' } 
      association :person, factory: :valid_person
      association :role_object, factory: :valid_collecting_event
    end

  end
end
