# A biological associations graph is...
#   @todo
#
# @!attribute project_id
#   the project ID
#
# @!attribute name
#   @todo
#
# @!attribute source_id
#   the source ID
#
class BiologicalAssociationsGraph < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::IsData 

  belongs_to :source
  has_many :biological_associations_biological_associations_graphs, inverse_of: :biological_associations_graph
  has_many :biological_associations, through: :biological_associations_biological_associations_graphs

end
