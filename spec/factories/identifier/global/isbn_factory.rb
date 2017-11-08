# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :identifier_global_isbn, :class => 'Identifier::Global::Isbn', traits: [:housekeeping] do
    factory :isbn_identifier do
      identifier 'ISBN-13: 978-0-596-52068-7'
    end
  end
end
