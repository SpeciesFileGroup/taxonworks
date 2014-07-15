# A biocuration class is used to organize a collection according to some biological categories (attributes).  
# For example, in an insect collection, this may be things like "adult", "pupae", "male", "female".  More
# generally they could be categories like "wet", "dry", "skulls", "furs".  It is important to note that
# these categorizations are for *organization*, they do not also assert that the colleciton object itself has
# the biological propert "maleness", or "adultness". Biocuration classes do help to answer the question "where might
# I find this in the collection."
#
class BiocurationClass < ControlledVocabularyTerm
  include Shared::Taggable

  has_many :biocuration_classifications, inverse_of: :biocuration_class
  has_many :biological_collection_objects, through: :biocuration_classifications, class_name: 'CollectionObject::BiologicalCollectionObject', inverse_of: :biocuration_classes

  def taggable_with
    %w{BiocurationGroup}
  end

end
