FactoryGirl.define do
  factory :asserted_distribution, traits: [:housekeeping] do
    factory :valid_asserted_distribution do
      association :otu, factory: :valid_otu
      association :geographic_area, factory: :valid_geographic_area
      association :source, factory: :valid_source
    end
  end
end
