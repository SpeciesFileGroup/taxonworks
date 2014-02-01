# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :public_content do
    otu nil
    topic nil
    text "MyText"
    version 1
    project nil
    created_by_id 1
    updated_by_id 1
  end
end
