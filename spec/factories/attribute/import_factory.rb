# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attribute_import, :class => 'Attribute::Import', traits: [:creator_and_updater] do
  end
end
