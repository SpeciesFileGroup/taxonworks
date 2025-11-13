# Index table for BiologicalAssociation data, used for fast querying and
# filtering.
class BiologicalAssociationIndex < ApplicationRecord
  include Housekeeping

  belongs_to :biological_association, inverse_of: :biological_association_index
  belongs_to :biological_relationship, inverse_of: :biological_association_indices
  belongs_to :project, inverse_of: :biological_association_indices

  validates_presence_of :biological_association
  validates_presence_of :biological_relationship
end
