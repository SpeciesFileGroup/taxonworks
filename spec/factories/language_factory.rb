# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :language, traits: [:creator_and_updater] do
    factory :valid_language do
      alpha_3_bibliographic "ABC"
      english_name "English"
    end
  end
end
