FactoryBot.define do
  factory :asserted_distribution, traits: [:housekeeping] do
    factory :valid_asserted_distribution do
      after(:build) do |asserted_distribution|
        FactoryProjectHelpers.assign_project_scoped(asserted_distribution, :asserted_distribution_object, :valid_otu)
      end
      association :asserted_distribution_shape, factory: :valid_geographic_area
      association :source, factory: :valid_source
    end

    factory :valid_geographic_area_asserted_distribution do
      after(:build) do |asserted_distribution|
        FactoryProjectHelpers.assign_project_scoped(asserted_distribution, :asserted_distribution_object, :valid_otu)
      end
      association :asserted_distribution_shape, factory: :valid_geographic_area
      association :source, factory: :valid_source
    end

    factory :valid_gazetteer_asserted_distribution do
      after(:build) do |asserted_distribution|
        FactoryProjectHelpers.assign_project_scoped(asserted_distribution, :asserted_distribution_object, :valid_otu)
      end
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end

    factory :valid_biological_association_asserted_distribution do
      after(:build) do |asserted_distribution|
        FactoryProjectHelpers.assign_project_scoped(asserted_distribution, :asserted_distribution_object, :valid_biological_association)
      end
      association :asserted_distribution_shape, factory: :valid_geographic_area
      association :source, factory: :valid_source
    end

    factory :valid_biological_associations_graph_asserted_distribution do
      after(:build) do |asserted_distribution|
        FactoryProjectHelpers.assign_project_scoped(asserted_distribution, :asserted_distribution_object, :valid_biological_associations_graph)
      end
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end

    factory :valid_conveyance_asserted_distribution do
      after(:build) do |asserted_distribution|
        FactoryProjectHelpers.assign_project_scoped(asserted_distribution, :asserted_distribution_object, :valid_conveyance)
      end
      association :asserted_distribution_shape, factory: :valid_geographic_area
      association :source, factory: :valid_source
    end

    factory :valid_depiction_asserted_distribution do
      after(:build) do |asserted_distribution|
        FactoryProjectHelpers.assign_project_scoped(asserted_distribution, :asserted_distribution_object, :valid_depiction)
      end
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end

    factory :valid_observation_asserted_distribution do
      after(:build) do |asserted_distribution|
        FactoryProjectHelpers.assign_project_scoped(asserted_distribution, :asserted_distribution_object, :valid_observation)
      end
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end

    factory :valid_otu_asserted_distribution do
      after(:build) do |asserted_distribution|
        FactoryProjectHelpers.assign_project_scoped(asserted_distribution, :asserted_distribution_object, :valid_otu)
      end
      association :asserted_distribution_shape, factory: :valid_geographic_area
      association :source, factory: :valid_source
    end
  end
end
