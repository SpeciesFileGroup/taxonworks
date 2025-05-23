FactoryBot.define do
  factory :asserted_distribution, traits: [:housekeeping] do
    factory :valid_asserted_distribution do
      association :otu, factory: :valid_otu
      association :asserted_distribution_shape, factory: :valid_geographic_area
      association :source, factory: :valid_source
    end

    factory :valid_geographic_area_asserted_distribution do
      association :otu, factory: :valid_otu
      association :asserted_distribution_shape, factory: :valid_geographic_area
      association :source, factory: :valid_source
    end

    factory :valid_gazetteer_asserted_distribution do
      association :otu, factory: :valid_otu
      association :asserted_distribution_shape, factory: :valid_gazetteer
      association :source, factory: :valid_source
    end
  end
end
