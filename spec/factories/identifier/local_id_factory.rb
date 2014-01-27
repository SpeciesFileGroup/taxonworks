# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_local_id, :class => 'Identifier::LocalId', traits: [:housekeeping] do
  end
end
