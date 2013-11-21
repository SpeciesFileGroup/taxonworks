class BiologicalAssociationsGraph < ActiveRecord::Base

  # include Shared::Citable

  has_many :biological_associations

end
