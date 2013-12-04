class ProjectMember < ActiveRecord::Base

  include Housekeeping::Users

  belongs_to :project, inverse_of: :project_members
  belongs_to :user, inverse_of: :project_members

  validates_presence_of :project_id, :user_id

end
