class BiocurationClassification < ActiveRecord::Base
  belongs_to :biocuration_class
  belongs_to :biological_collection_object

  validates_presence_of :biocuration_class, :biological_collection_object

end
