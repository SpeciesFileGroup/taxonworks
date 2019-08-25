# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :identifier_global_doi, class: 'Identifier::Global::Doi', traits: [:housekeeping] do
    factory :doi_identifier do
      identifier { "10.#{Faker::Number.decimal(l_digits: 4, r_digits: 4)}/TaxonWorks-#{Faker::Number.number(digits: 45)}" }
    end
  end
end
