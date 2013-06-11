class BiologicalRelationshipProperty < ActiveRecord::Base
  belongs_to :biological_property_id
  belongs_to :biological_relationship_id
end
