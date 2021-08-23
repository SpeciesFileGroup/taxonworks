# The proxy for a DwC occurrenceID if no other UUID for a given instance is present.
#
# Created automatically during DwC indexing if not present.
#
class Identifier::Global::Uuid::TaxonworksDwcOccurrence < Identifier::Global::Uuid

  validate :object_may_be_a_dwc_occurrence

  def object_may_be_a_dwc_occurrence
    a = identifier_object_type&.safe_constantize
    a ||= identifier_object.class.name
    unless a.dwc_occurrence_eligible?
      errors.add(:identifier_object_type, "#{identifier_object_type} can not be indexed as a DwC occurrence")
    end
  end

end
