FactoryGirl.define do

  trait :creator_and_updater do
    creator { User.find(1) }
    updater { creator }
  end

  trait :projects do
    project { Project.find(1) }
  end 

  trait :housekeeping  do
    creator_and_updater
    projects 
  end

end
