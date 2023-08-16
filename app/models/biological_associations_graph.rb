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
# @!attribute graph
#   @return [Json]
#      a layout for the graph
#      
class BiologicalAssociationsGraph < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Notes
  include Shared::Tags
  include Shared::Identifiers
  include Shared::IsData

  has_many :biological_associations_biological_associations_graphs, inverse_of: :biological_associations_graph, dependent: :delete_all
  has_many :biological_associations, through: :biological_associations_biological_associations_graphs

  accepts_nested_attributes_for  :biological_associations_biological_associations_graphs, allow_destroy: true

end
