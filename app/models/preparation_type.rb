class PreparationType < ActiveRecord::Base
  
  # TODO: 1:1 or 1:many?

  has_many :biological_collection_objects
  validates_presence_of :name

end
