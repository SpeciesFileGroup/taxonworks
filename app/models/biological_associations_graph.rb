class BiologicalAssociationsGraph < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable

  belongs_to :source
  has_many :biological_associations_biological_associations_graphs, inverse_of: :biological_associations_graph
  has_many :biological_associations, through: :biological_associations_biological_associations_graphs

end
