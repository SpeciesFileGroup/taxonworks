class PreparationType < ActiveRecord::Base
  
  has_many :collection_objects
  validates_presence_of :name

end
