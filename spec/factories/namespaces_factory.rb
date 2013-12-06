FactoryGirl.define do
  factory :namespace, traits: [:creator_and_updater] do
    factory :valid_namespace do
      name 'All my things'
      short_name 'AMT'
    end
  end
end
