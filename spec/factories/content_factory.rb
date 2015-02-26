FactoryGirl.define do
  factory :content, traits: [:housekeeping] do
    factory :valid_content do
      association :otu, factory: :valid_otu
      association :topic, factory: :valid_topic
      text "MyText"
    end
  end
end
