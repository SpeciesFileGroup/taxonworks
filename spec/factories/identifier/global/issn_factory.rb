# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :identifier_global_issn, class: 'Identifier::Global::Issn', traits: [:housekeeping] do
    factory :issn_identifier do
         identifier '0317-8471'
    end
  end
end
