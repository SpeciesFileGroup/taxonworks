class BiologicalAssociationsGraph < ActiveRecord::Base

  has_many :biological_associations

  validates_presence_of :name
  
end
