FactoryGirl.define do
  factory :human_source, class: Source::Human, traits: [:creator_and_updater] do
    factory :valid_human_source do
      association :person, factory: :valid_person
    end
  end
end
