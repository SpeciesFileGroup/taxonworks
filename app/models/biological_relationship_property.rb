class BiologicalRelationshipProperty < ActiveRecord::Base
  belongs_to :biological_property
  belongs_to :biological_relationship
end
