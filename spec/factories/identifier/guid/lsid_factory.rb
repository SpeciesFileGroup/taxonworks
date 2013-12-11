# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_guid_lsid, :class => 'Identifier::Guid::Lsid', traits: [:housekeeping] do
  end
end
