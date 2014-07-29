# SourceSource is a Role
FactoryGirl.define do
  factory :source_source, class: SourceSource, traits: [:creator_and_updater] do
    factory :valid_source_source do
      association :person, factory: :valid_person
      association :role_object, factory: :valid_source_human
    end

  end
end
