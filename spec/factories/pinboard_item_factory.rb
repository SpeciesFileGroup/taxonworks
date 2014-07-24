FactoryGirl.define do
  factory :pinboard_item, traits: [:housekeeping] do
    factory :valid_pinboard_item do
      association :user, factory: :valid_user
      association :pinned_object, factory: :valid_otu
    end 
  end
end
