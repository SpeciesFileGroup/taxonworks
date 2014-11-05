class ProjectMember < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::IsData 

  belongs_to :project, inverse_of: :project_members
  belongs_to :user, inverse_of: :project_members

  validates :project, presence: true
  validates :user, presence: true
  validates_uniqueness_of :user_id, scope: [:project_id]

end
