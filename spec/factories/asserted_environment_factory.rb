FactoryBot.define do
  factory :asserted_environment, traits: [:housekeeping] do
    sequence(:uri) { |n| "http://purl.obolibrary.org/obo/ENVO_#{n.to_s.rjust(8, '0')}" }
    uri_label { 'temperate forest biome' }

    factory :valid_asserted_environment do
      after(:build) do |asserted_environment|
        FactoryProjectHelpers.assign_project_scoped(asserted_environment, :asserted_environment_object, :valid_otu)
      end
    end

    factory :valid_otu_asserted_environment do
      after(:build) do |asserted_environment|
        FactoryProjectHelpers.assign_project_scoped(asserted_environment, :asserted_environment_object, :valid_otu)
      end
    end

    factory :valid_collecting_event_asserted_environment do
      after(:build) do |asserted_environment|
        FactoryProjectHelpers.assign_project_scoped(asserted_environment, :asserted_environment_object, :valid_collecting_event)
      end
    end

    factory :valid_gazetteer_asserted_environment do
      after(:build) do |asserted_environment|
        FactoryProjectHelpers.assign_project_scoped(asserted_environment, :asserted_environment_object, :valid_gazetteer)
      end
    end
  end
end
