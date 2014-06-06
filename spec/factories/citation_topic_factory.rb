# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :citation_topic, traits: [:housekeeping] do
    topic nil
    citation nil
    pages "MyString"

    factory :valid_citation_topic do
      topic {FactoryGirl.build(:valid_topic)}
      citation {FactoryGirl.build(:valid_citation)}
    end
  end
end
