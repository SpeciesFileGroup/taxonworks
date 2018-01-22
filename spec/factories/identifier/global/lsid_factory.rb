# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :identifier_global_lsid, class: 'Identifier::Global::Lsid', traits: [:housekeeping] do
  end
end
