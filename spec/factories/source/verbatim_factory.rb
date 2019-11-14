FactoryBot.define do
  factory :source_verbatim, class: 'Source::Verbatim', traits: [:creator_and_updater] do
    factory :valid_source_verbatim do
      verbatim { Faker::Lorem.words(number: 6).join(' ') }
    end
  end
end
