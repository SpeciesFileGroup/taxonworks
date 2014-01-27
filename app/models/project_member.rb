class ProjectMember < ActiveRecord::Base

  include Housekeeping::Users

  belongs_to :project, inverse_of: :project_members
  belongs_to :user, inverse_of: :project_members

  validates :project, presence: true
  validates :user, presence: true

end
