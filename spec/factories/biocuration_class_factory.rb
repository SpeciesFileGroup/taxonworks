# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :biocuration_class, traits: [:housekeeping] do
    name "MyString"
  end
end
