FactoryBot.define do
  factory :depiction, traits: [:creator_and_updater] do
    factory :valid_depiction do
      association :image, factory: :tiny_random_image
      association :depiction_object, factory: :valid_specimen
    end
  end

  factory :depiction_logo, class: 'Depiction::Logo', traits: [:creator_and_updater] do
    factory :valid_depiction_logo do
      association :image, factory: :valid_svg_image
      association :depiction_object, factory: :valid_organization
    end
  end

end
