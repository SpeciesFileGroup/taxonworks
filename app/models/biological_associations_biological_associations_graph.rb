# A biological associations biological associations graph is...
#   @todo
#
# @!attribute biological_association_graph_id
#   @return [Integer]
#   @todo
#
# @!attribute biological_association_id
#   @return [Integer]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class BiologicalAssociationsBiologicalAssociationsGraph < ApplicationRecord
  include Housekeeping
  include Shared::IsData
  
  belongs_to :biological_associations_graph, inverse_of: :biological_associations_biological_associations_graphs
 
  belongs_to :biological_association, inverse_of: :biological_associations_biological_associations_graphs

  validates :biological_associations_graph, presence: true
  validates :biological_association, presence: true

  validates_uniqueness_of :biological_association, scope: [ :biological_associations_graph ]

end
