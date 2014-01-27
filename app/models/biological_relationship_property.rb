class BiologicalRelationshipProperty < ActiveRecord::Base

  include Housekeeping

  belongs_to :biological_property
  belongs_to :biological_relationship
end
