FactoryGirl.define do
  factory :role do
  end

  factory :source_author_role, class: SourceAuthor do
    association :person, factory: :valid_person
    association :role_object, factory: :valid_bibtex_source 
  end

  factory :source_author_without_person, class: SourceAuthor do
    association :role_object, factory: :valid_bibtex_source 
  end

  factory :source_source_role, class: SourceSource do
    association :person, factory: :valid_person
    association :role_object, factory: :valid_human_source
  end


end
