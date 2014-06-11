# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :otu_page_layout_section, traits: [:housekeeping] do
    factory :valid_otu_page_layout_section do
      association :otu_page_layout, factory: :valid_otu_page_layout
      association :topic, factory: :valid_topic
      type 'OtuPageLayoutSection::StandardSection'
    end
  end
end
