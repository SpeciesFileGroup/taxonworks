FactoryGirl.define do
  factory :preparation_type, traits: [:creator_and_updater] do
    name "Pinned"
    factory :valid_preparation_type  do
      definition 'Impaled with a tiny pointy metal pole.'
    end

  end
end
