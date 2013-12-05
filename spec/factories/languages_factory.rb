# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :language do
    alpha_3_bibliographic "ABC"
    english_name "French"
  end

  factory :valid_language, class: Language do
    alpha_3_bibliographic "ABC"
    english_name "English"
  end

end
