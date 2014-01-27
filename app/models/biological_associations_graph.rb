class BiologicalAssociationsGraph < ActiveRecord::Base

  # include Shared::Citable

  include Housekeeping

  has_many :biological_associations

end
