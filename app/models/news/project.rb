
# Project news is related to the content of the current project.  
#
# At present any ProjectMember can create Project news. If this gets abused we'll restrict it to project_administrators.
# 
class News::Project < News
  include Housekeeping::Users
  include Housekeeping::Projects
  include Housekeeping::Timestamps

  validates :project_id, absence: false
end
