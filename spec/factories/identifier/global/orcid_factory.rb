# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :identifier_global_orcid, :class => 'Identifier::Global::Orcid', traits: [:housekeeping] do
  end
end
