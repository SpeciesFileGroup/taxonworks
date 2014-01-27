# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_guid, :class => 'Identifier::Guid', traits: [:housekeeping] do
  end
end
