# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :container_label, traits: [:housekeeping] do
    factory :valid_container_label do
      association :container, factory: :valid_container
      label "MyText"
      print_style "MyString" 
    end
  end
end
