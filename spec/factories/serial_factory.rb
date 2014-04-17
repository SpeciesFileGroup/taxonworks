FactoryGirl.define do
  factory :serial, traits: [:creator_and_updater]  do
    factory :valid_serial do
      name 'Serial 1'
    end

    factory :preceding_serial do
      name 'Serial 0'
    end

    factory :succeeding_serial do
      name 'Serial 2'
    end
  end
end
