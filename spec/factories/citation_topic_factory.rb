# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :citation_topic, traits: [:housekeeping] do
    topic nil
    citation nil
    pages "MyString"
  end
end
