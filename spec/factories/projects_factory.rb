FactoryGirl.define do
  factory :project, class: Project, traits: [:creator_and_updater] do
    # Don't include a name here 
    factory :valid_project do
      name 'My Project'
    end
  end
end
