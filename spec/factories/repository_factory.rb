FactoryGirl.define do
  factory :repository, traits: [:creator_and_updater] do
    factory :valid_repository do
      name "Fort Knocks"
      url "http://lotsof.gold.com"
      acronym "SOHN"
      status "boolean?"
    end
  end
end

