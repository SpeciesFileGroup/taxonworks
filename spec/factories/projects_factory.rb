# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name "MyString"
  end

  factory :valid_project, class: Project do
    name "MyString"
  end
end
