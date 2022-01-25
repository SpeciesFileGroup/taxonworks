# A BiocurationClass is used with BiocurationClassification to organize a collection according to some biological categories (attributes).
# Biocuration classes help to answer the question "where might I find this in the collection."
#
# For example, in an insect collection, this may be things like "adult", "pupae", "male", "female".  More
# generally they could be categories like "skulls", "furs", or perhaps even "wet" or "dry".  It is important to note that
# these categorizations are for *organization* and *curatorial* purposes, they are not primary assertions that the collection object itself has
# the biological property "maleness", or "adultness".  That is, in most, but not all, cases we can _infer_ that the classification means that the collection object
# is a "male" or "adult". 
#
class BiocurationClass < ControlledVocabularyTerm
  include Shared::Tags

  has_many :biocuration_classifications, inverse_of: :biocuration_class, dependent: :restrict_with_error
  has_many :biological_collection_objects, through: :biocuration_classifications, class_name: 'CollectionObject::BiologicalCollectionObject', inverse_of: :biocuration_classes

  after_save :check_dwc_occurrence_basis

  def taggable_with
    %w{BiocurationGroup}
  end

  protected

  def check_dwc_occurrence_basis
    if saved_change_to_attribute?(:uri, from: DWC_FOSSIL_URI)
      biological_collection_objects.each do |o|
        o.dwc_occurrence.update_attribute(:basisOfRecord, 'PreservedSpecimen')
      end
    end

    if saved_change_to_attribute?(:uri, to: DWC_FOSSIL_URI)
      biological_collection_objects.each do |o|
        o.dwc_occurrence.update_attribute(:basisOfRecord, 'FossilSpecimen')
      end
    end
  end



end
