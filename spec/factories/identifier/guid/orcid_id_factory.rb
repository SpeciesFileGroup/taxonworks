# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_guid_orcid_id, :class => 'Identifier::Guid::OrcidId', traits: [:housekeeping] do
  end
end
