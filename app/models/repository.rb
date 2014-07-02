# Repositories are built exclusively at http://grbio.org/.  
class Repository < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::Notable

  has_many :collection_objects, inverse_of: :repository
  validates_presence_of :name, :url, :acronym, :status
end
