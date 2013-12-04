class PreparationType < ActiveRecord::Base

  include Housekeeping::Users

  has_many :collection_objects
  validates_presence_of :name

end
