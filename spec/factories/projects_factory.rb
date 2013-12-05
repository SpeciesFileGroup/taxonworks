# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :base_project, class: Project do
    name 'My Project'

    factory :project do
    end

    factory :valid_project do
    end
  end
end
