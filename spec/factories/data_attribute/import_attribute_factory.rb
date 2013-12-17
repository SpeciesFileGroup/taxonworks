# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :data_attribute_import_attribute, :class => 'DataAttribute::ImportAttribute', traits: [:creator_and_updater] do
  end
end
