FactoryBot.define do
  factory :topic, traits: [:housekeeping] do
    factory :valid_topic, traits: [:random_name, :random_definition]
  end
end
