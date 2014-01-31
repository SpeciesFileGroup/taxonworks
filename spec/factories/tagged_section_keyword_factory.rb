# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tagged_section_keyword do
    otu_page_layout_section nil
    keyword_references "MyString"
    position 1
    created_by_id 1
    updated_by_id 1
    project nil
  end
end
