class BiocurationClassification < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 
  
  belongs_to :biocuration_class, inverse_of: :biocuration_classifications
  belongs_to :biological_collection_object, class_name: 'CollectionObject::BiologicalCollectionObject', inverse_of: :biocuration_classifications

  validates_presence_of :biocuration_class, :biological_collection_object

end
