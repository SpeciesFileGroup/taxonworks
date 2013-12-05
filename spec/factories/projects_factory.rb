FactoryGirl.define do
 #factory :project, class: Project do
 #  name 'My Project'

 #  factory :valid_project, traits: [:creator_and_updater] do
 #    name 'Valid Project Name'
 #  end

 #  factory :test_project do
 #    name 'Test Project'
 #  end
  #end
 factory :valid_project, class: Project do
   name 'A Valid Project'
 end

end
