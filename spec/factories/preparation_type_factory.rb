# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :preparation_type, traits: [:creator_and_updater] do
    name "MyString"
  end
end
