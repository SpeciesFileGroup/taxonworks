class PreparationType < ActiveRecord::Base
  include Housekeeping::Users
  has_many :collection_objects, dependent: :restrict_with_error
  validates_presence_of :name
end
