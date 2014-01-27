# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_guid_isbn, :class => 'Identifier::Guid::Isbn', traits: [:housekeeping] do
  end
end
