class BiologicalAssociationsBiologicalAssociationsGraph < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 


  belongs_to :biological_associations_graph, inverse_of: :biological_associations_biological_associations_graphs
  belongs_to :biological_association, inverse_of: :biological_associations_biological_associations_graphs

  validates :biological_associations_graph, presence: true
  validates :biological_association, presence: true
end
