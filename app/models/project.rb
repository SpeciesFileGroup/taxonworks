class Project < ActiveRecord::Base

  has_many :project_members
  has_many :users, through: :project_members

  validates_presence_of :name
end
