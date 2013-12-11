# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_guid_doi, :class => 'Identifier::Guid::Doi', traits: [:housekeeping] do
  end
end
