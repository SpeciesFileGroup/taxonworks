# SourceSource is a Role
FactoryGirl.define do
  factory :source_author, class: SourceAuthor, traits: [:creator_and_updater] do
    factory :valid_source_author do
      association :person, factory: :valid_person
      association :role_object, factory: :valid_source_bibtex
    end

    factory :valid_role_source_role_source_author do
      association :person, factory: :valid_person
      association :role_object, factory: :valid_source_bibtex
    end
  end
end
