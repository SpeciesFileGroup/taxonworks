# 
# !! DEPRECATED
#
# The Local Identifier that is used by collectors to uniquely identify collecting events.
#
class Identifier::Local::TripCode < Identifier::Local

  include Shared::DwcOccurrenceHooks

  validate :deprecated

  def dwc_occurrences
    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins('JOIN collecting_events ce on ce.id = co.collecting_event_id')
      .joins("JOIN identifiers i on i.identifier_object_id = ce.id AND i.identifier_object_type = 'CollectingEvent'")
      .where(i: {id:})
      .distinct
  end

  private

  # Always prevent use of this class
  def deprecated
    errors.add(:identifier_object_type, 'TripCode is deprecated for FieldNumber, please use FieldNumber identifiers') 
  end
end

