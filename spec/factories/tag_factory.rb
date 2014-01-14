FactoryGirl.define do
  factory :tag, traits: [:housekeeping] do
    factory :valid_tag do
      association :tag_object, factory: :valid_otu
      association :keyword, factory: :valid_keyword
    end
  end
end
