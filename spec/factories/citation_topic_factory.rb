# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :citation_topic, traits: [:housekeeping] do
    topic nil
    citation nil
    pages "MyString"

    factory :valid_citation_topic do
      association :topic, factory: :valid_topic
      association :citation, factory: :valid_citation
    end
  end
end
