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
  include Shared::DwcOccurrenceHooks

  has_many :biocuration_classifications, inverse_of: :biocuration_class, dependent: :restrict_with_error

  has_many :collection_objects, through: :biocuration_classifications, source: :biocuration_classification_object, inverse_of: :biocuration_classifications, source_type: 'CollectionObject'
  has_many :field_occurrences, through: :biocuration_classifications, source: :biocuration_classification_object, inverse_of: :biocuration_classifications, source_type: 'FieldOccurrence'

  # TODO: probably can remove
  after_save :check_dwc_occurrence_basis

  def taggable_with
    %w{BiocurationGroup}
  end

  def dwc_occurrences
    # Remember that classes must be tagged by a corresponding group with a URI to
    # become eligible as values for "grouped" Dwc attributes.
    if keywords.where(uri: ::DWC_ATTRIBUTE_URIS.values.flatten).any?
      ::Queries::DwcOccurrence::Filter.new(
        collection_object_query: {
          biocuration_class_id: id
        }
      ).all

    else
      DwcOccurrence.none
    end
  end

  protected

  def check_dwc_occurrence_basis
    if saved_change_to_attribute?(:uri, from: DWC_FOSSIL_URI)
      collection_objects.each do |o|
        o.dwc_occurrence.update_attribute(:basisOfRecord, 'PreservedSpecimen')
      end
    end

    if saved_change_to_attribute?(:uri, to: DWC_FOSSIL_URI)
      collection_objects.each do |o|
        o.dwc_occurrence.update_attribute(:basisOfRecord, 'FossilSpecimen')
      end
    end
  end

end
