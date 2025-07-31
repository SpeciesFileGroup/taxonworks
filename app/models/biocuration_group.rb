# A Tag that groups (classifies) BiocurationClasses
class BiocurationGroup < Keyword 

  include Shared::DwcOccurrenceHooks

  def dwc_occurrences
    ids = biocuration_classes.map(&:id)
    return DwcOccurrence.none if ids.empty?

    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins("JOIN biocuration_classifications bc on bc.biocuration_classification_object_type = 'CollectionObject' and bc.biocuration_classification_object_id = co.id AND biocuration_class_id IN (#{ids.join(',')})")
  end

  # This could ultimately be SQL'ed out 
  def biocuration_classes
    tagged_objects
  end

  def can_tag
    %w{BiocurationClass}
  end

end
