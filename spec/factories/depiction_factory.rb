FactoryGirl.define do
  factory :depiction, traits: [:creator_and_updater] do
    factory :valid_depiction do
      association :image, factory: :valid_image
      association :depiction_object, factory: :valid_specimen
    end
  end

end
