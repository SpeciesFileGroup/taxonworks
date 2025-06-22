FactoryBot.define do
  factory :asserted_distribution, traits: [:housekeeping] do
    factory :valid_asserted_distribution do
      association :asserted_distribution_object, factory: :valid_otu
      association :asserted_distribution_shape, factory: :valid_geographic_area
      association :source, factory: :valid_source
    end

    factory :valid_geographic_area_asserted_distribution do
      association :asserted_distribution_object, factory: :valid_otu
      association :asserted_distribution_shape, factory: :valid_geographic_area
      association :source, factory: :valid_source
    end

    factory :valid_gazetteer_asserted_distribution do
      association :asserted_distribution_object, factory: :valid_otu
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end

    factory :valid_biological_association_asserted_distribution do
      association :asserted_distribution_object, factory: :valid_biological_association
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end

    factory :valid_biological_associations_graph_asserted_distribution do
      association :asserted_distribution_object, factory: :valid_biological_associations_graph
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end

    factory :valid_conveyance_asserted_distribution do
      association :asserted_distribution_object, factory: :valid_conveyance
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end

    factory :valid_depiction_asserted_distribution do
      association :asserted_distribution_object, factory: :valid_depiction
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end

    factory :valid_observation_asserted_distribution do
      association :asserted_distribution_object, factory: :valid_observation
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end

    factory :valid_otu_asserted_distribution do
      association :asserted_distribution_object, factory: :valid_otu
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end
  end
end
