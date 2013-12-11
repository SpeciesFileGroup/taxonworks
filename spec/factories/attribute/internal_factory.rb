# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attribute_internal, :class => 'Attribute::Internal', traits: [:housekeeping] do
  end
end
