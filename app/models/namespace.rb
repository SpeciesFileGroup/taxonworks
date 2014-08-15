class Namespace < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::SharedAcrossProjects

  validates_presence_of :name, :short_name
  validates_uniqueness_of :name, :short_name

  has_many :identifiers, dependent: :restrict_with_error
end
