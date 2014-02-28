# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :container_label do
    label "MyText"
    date_printed "2014-02-26"
    print_style "MyString"
    position 1
    created_by_id 1
    modified_by_id 1
    project_id 1
  end
end
