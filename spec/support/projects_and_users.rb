
def clean_slate 
  Project.delete_all 
  User.delete_all
  ProjectMember.delete_all
  $user_id = nil
  $project_id = nil
end

RSpec.configure do |config|
  config.before(:suite) { 
    # Order matters 
    FactoryGirl.create(:valid_user, id: 1)
    $user_id = 1
    FactoryGirl.create(:valid_project, id: 1)
    $project_id = 1
    FactoryGirl.create(:project_member, user_id: 1, project_id: 1)
  } 

  config.after(:suite) { 
    clean_slate
  }
end

