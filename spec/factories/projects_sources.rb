# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projects_source, :class => 'ProjectsSources' do
    project nil
    source nil
    created_by_id 1
    updated_by_id 1
  end
end
