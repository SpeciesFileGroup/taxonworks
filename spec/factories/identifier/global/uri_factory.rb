# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identifier_global_uri, :class => 'Identifier::Global::Uri', traits: [:housekeeping] do
    factory :uri_identifier do
      identifier 'http://orthoptera.speciesfile.org'
    end
  end
end
