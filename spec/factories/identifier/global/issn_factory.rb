# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_global_issn, :class => 'Identifier::Global::Issn', traits: [:housekeeping] do
  end
end
