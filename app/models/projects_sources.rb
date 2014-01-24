class ProjectsSources < ActiveRecord::Base
  belongs_to :project
  belongs_to :source
  validates :project, presence: true
  validates :source, presence: true
end
