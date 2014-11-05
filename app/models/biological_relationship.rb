class BiologicalRelationship < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 

  validates_presence_of :name
  has_many :biological_relationship_types, inverse_of: :biological_relationship
  has_many :biological_associations, inverse_of: :biological_relationship
  has_many :biological_properties, through: :biological_relationship_types

end
