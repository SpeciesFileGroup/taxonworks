# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_guid_lccn, :class => 'Identifier::Guid::Lccn', traits: [:housekeeping] do
  end
end
