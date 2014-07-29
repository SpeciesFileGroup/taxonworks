# TODO: Unsatisfactory validation, should (only?) invoke with acceptes_nested_attributes_for
FactoryGirl.define do
  factory :source_human, :class => Source::Human, traits: [:creator_and_updater] do
    factory :valid_source_human 
  end
end
