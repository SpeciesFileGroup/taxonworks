FactoryGirl.define do
  factory :project, class: Project do
    name 'My Project'
    factory :valid_project, traits: [:creator_and_updater] 
  end
end
