# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :otu_page_layout_section do
    otu_page_layout nil
    type ""
    position 1
    topic nil
    dynamic_content_class "MyString"
  end
end
