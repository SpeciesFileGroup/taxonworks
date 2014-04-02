
def clean_slate 
  Project.delete_all 
  User.delete_all
  ProjectMember.delete_all
  $user_id = nil
  $project_id = nil
end

RSpec.configure do |config|
  config.before(:suite) { 
    clean_slate
    # Order matters 
    FactoryGirl.create(:valid_user, id: 1)
    $user_id = 1
    FactoryGirl.create(:valid_project, id: 1)
    $project_id = 1
    FactoryGirl.create(:project_member, user_id: 1, project_id: 1)

    # TODO: This is here for Rake based testing purposes, it's a little worriesome that it is needed.
    ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.reset_pk_sequence!(t) }
  } 

  config.after(:suite) { 
    clean_slate
  }


end

