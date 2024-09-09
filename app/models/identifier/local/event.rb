# The identifier sensu DarwinCore eventID https://dwc.tdwg.org/terms/#dwc:eventID.
#
# See also FieldNumber.
#
# In TW we assume it differs from FieldNumber:
#  - can be assigned via machine-originating processes (typically not to be the case on FieldNumber)
#  - think of it as an accession  (="assigned while taking in the date") code for CollectingEvents
#
class Identifier::Local::Event < Identifier::Local

  include Shared::DwcOccurrenceHooks

  validate :assigned_to_collecting_event

  def dwc_occurrences
    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins("JOIN identifiers i on i.identifier_object_id = co.collecting_event_id AND i.identifier_object_type = 'CollectingEvent'")
      .where(i: {id:})
      .distinct
  end

  private

  def assigned_to_collecting_event
    errors.add(:identifier_object_type, 'only assignable to CollectingEvents') if (identifier_object_type && identifier_object_type != 'CollectingEvent') || (identifier_object && !identifier_object.kind_of?(CollectingEvent))
  end

end
