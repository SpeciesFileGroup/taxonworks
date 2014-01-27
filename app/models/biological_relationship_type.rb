class BiologicalRelationshipType < ActiveRecord::Base
  include Housekeeping

  belongs_to :biological_property, inverse_of: :biological_relationship_types
  belongs_to :biological_relationship, inverse_of: :biological_relationship_types

  validates_presence_of :type
  validates :biological_property, presence: true
  validates :biological_relationship, presence: true
end
