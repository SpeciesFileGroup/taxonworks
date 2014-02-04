# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tagged_section_keyword, traits: [:housekeeping] do
    factory :valid_tagged_section_keyword do
      association :keyword, factory: :valid_keyword
      association :otu_page_layout_section, factory: :valid_otu_page_layout_section
    end
  end
end
