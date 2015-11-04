# A ProjectMember is the link between projects and users.  
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute user_id
#   @return [Integer]
#     the user 
#
# @!attribute is_project_administrator
#   @return [Boolean]
#    whether the user is a project administrator 
#
class ProjectMember < ActiveRecord::Base
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::IsData 

  belongs_to :project, inverse_of: :project_members
  belongs_to :user, inverse_of: :project_members

  validates :project, presence: true
  validates :user, presence: true
  validates_uniqueness_of :user_id, scope: [:project_id], message: 'is already a member of project'

end
