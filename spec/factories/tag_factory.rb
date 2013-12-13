# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tag, traits: [:housekeeping] do
    keyword nil
    tag_object_id 1
    tag_object_type "MyString"
    tag_object_attribute "MyString"
  end
end
