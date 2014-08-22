FactoryGirl.define do
  factory :role, traits: [:creator_and_updater] do
    factory :valid_role do
      type 'SourceAuthor'
      association :person, factory: :valid_person
      association :role_object, factory: :valid_source_bibtex
    end
  end
end
