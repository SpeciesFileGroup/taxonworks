class Protocol < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  belongs_to :project

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
  validates_presence_of :short_name
  validates_presence_of :description
end
