
FactoryGirl.define do
  factory :role do
  end

  factory :base_source_author_role, class: SourceAuthor, traits: [:creator_and_updater] do

    factory :source_author_role do
      association :person, factory: :valid_person
      association :role_object, factory: :valid_bibtex_source 
    end

    factory :source_author_without_person do
      association :role_object, factory: :valid_bibtex_source 
    end

    factory :source_source_role do
      association :person, factory: :valid_person
      association :role_object, factory: :valid_human_source
    end

  end


end
