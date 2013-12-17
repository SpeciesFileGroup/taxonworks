# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :data_attribute_internal_attribute, :class => 'DataAttribute::InternalAttribute', traits: [:housekeeping] do
  end
end
