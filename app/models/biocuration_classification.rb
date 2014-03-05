class BiocurationClassification < ActiveRecord::Base
  include Housekeeping

  belongs_to :biocuration_class
  belongs_to :biological_collection_object

  validates_presence_of :biocuration_class, :biological_collection_object

  # TODO: scope to 'organismal/biological axis'

end
