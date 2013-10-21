FactoryGirl.define do
  factory :role do
  end

  factory :source_author_role, class: Role::SourceAuthor do
    association :person, factory: :valid_person
    association :role_object, factory: :bibtex_source 
  end

  factory :source_author_without_person, class: Role::SourceAuthor do
    association :role_object, factory: :bibtex_source 
  end

end
