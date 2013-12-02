class BiologicalRelationship < ActiveRecord::Base

  include Housekeeping

  validates_presence_of :name
  has_many :biological_properties
  has_many :domain_properties, class_name: :biological_relationship_domain_properties 
  has_many :range_properties, class_name: :biological_relationship_range_properties 
  has_many :biological_associations

end
