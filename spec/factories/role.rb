FactoryGirl.define do
  factory :source_author_role, class: Role::SourceAuthor do
    association :person, factory: :valid_person
    association :role_object, factory: :bibtex_source 
  end
end
