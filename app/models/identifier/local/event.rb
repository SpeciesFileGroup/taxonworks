# The identifier sensu DarwinCore eventID https://dwc.tdwg.org/terms/#dwc:eventID.
#
# See also TripCode. 
#
# In TW we assume it differs from TripCode: 
#  - can be assigned via machine-originating processes (typically not to be the case on TripCode)
#  - think of it as an accession  (="assigned while taking in the date") code for CollectingEvents
#
class Identifier::Local::Event < Identifier::Local

  include Shared::DwcOccurrenceHooks

  validate :assigned_to_collecting_event

  def assigned_to_collecting_event
    errors.add(:identifier_object_type, 'only assignable to CollectingEvents') if (identifier_object_type && identifier_object_type != 'CollectingEvent') || (identifier_object && !identifier_object.kind_of?(CollectingEvent))
  end

  def dwc_occurrences
    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins('JOIN collecting_events ce on ce.id = co.collecting_event_id')
      .joins("JOIN identifiers i on i.identifier_object_id = ce.id AND i.identifier_object_type = 'CollectingEvent'")
      .where(i: {id:})
      .distinct
  end

end
