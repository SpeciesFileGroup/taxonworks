# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_guid_uuid, :class => 'Identifier::Guid::Uuid', traits: [:housekeeping] do
  end
end
