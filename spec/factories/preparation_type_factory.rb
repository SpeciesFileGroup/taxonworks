FactoryGirl.define do
  factory :preparation_type, traits: [:creator_and_updater] do
    name "MyString"
    factory :valid_preparation_type 
  end
end
