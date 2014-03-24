# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_guid_lccn, :class => 'Identifier::Global::Lccn', traits: [:housekeeping] do
  end
end
