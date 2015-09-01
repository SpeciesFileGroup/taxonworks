# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_global_doi, :class => 'Identifier::Global::Doi', traits: [:housekeeping] do
    factory :doi_identifier do
      identifier '10.' + Faker::Number.decimal(4, 4) + '/TaxonWorks-' + Faker::Number.number(45)
    end
  end
end
