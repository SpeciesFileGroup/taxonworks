FactoryBot.define do

  trait :creator_and_updater do
    created_by_id { $factories_user.id }
    updated_by_id { $factories_user.id }
  end

  trait :projects do
    project_id { $factories_project.id }
  end

  trait :housekeeping do
    creator_and_updater
    projects
  end

end
