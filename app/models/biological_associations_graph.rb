# A biological associations graph is a collection of BiologicalAssociations.  For example, a citable foodweb.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute name
#   @return [String]
#     the name of the graph
#
class BiologicalAssociationsGraph < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::IsData

  has_many :biological_associations_biological_associations_graphs, inverse_of: :biological_associations_graph
  has_many :biological_associations, through: :biological_associations_biological_associations_graphs

end
