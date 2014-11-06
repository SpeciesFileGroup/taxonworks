# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :source_verbatim, class: 'Source::Verbatim', traits: [:creator_and_updater] do
    factory :valid_source_verbatim do
      verbatim Faker::Lorem.words(6)
    end
  end
end
