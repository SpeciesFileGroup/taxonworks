class TypeSpecimen < ActiveRecord::Base
  belongs_to :biological_object
  belongs_to :taxon_name
end
