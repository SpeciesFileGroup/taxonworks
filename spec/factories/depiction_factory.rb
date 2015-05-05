FactoryGirl.define do
  factory :depiction, traits: [:creator_and_updater] do
    factory :valid_depiction do
      image :valid_image
      depiction_object :valid_specimen
    end
  end

end
