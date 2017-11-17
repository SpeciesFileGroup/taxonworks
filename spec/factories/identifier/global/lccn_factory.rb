# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :identifier_global_lccn, :class => 'Identifier::Global::Lccn', traits: [:housekeeping] do
  end
end
