# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :public_content, traits: [:housekeeping] do
    factory :valid_public_content do
      association :otu,   factory: :valid_otu
      association :topic, factory: :valid_topic
      association :content, factory: :valid_content
      text "MyText" 
    end
  end
end
