# The identifier sensu DarwinCore eventID https://dwc.tdwg.org/terms/#dwc::FieldNumber
#
# Historically/ TW treated this as a Identifier::Local::TripCode
#
class Identifier::Local::FieldNumber < Identifier::Local

  include Shared::DwcOccurrenceHooks

  validate :assigned_to_collecting_event
  validate :same_as_verbatim

  def dwc_occurrences
    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins("JOIN identifiers i on i.identifier_object_id = co.collecting_event_id AND i.identifier_object_type = 'CollectingEvent'")
      .where(i: {id:})
      .distinct
  end

  private

  def same_as_verbatim
    unless errors.any? || !identifier_object.present?
      if identifier_object.verbatim_field_number.present? && build_cached !=  identifier_object.verbatim_field_number
        errors.add(:identifier, 'not identical to CollectingEvent verbatim_field_number')
      end
    end
  end

  def assigned_to_collecting_event
    errors.add(:identifier_object_type, 'only assignable to CollectingEvents') if (identifier_object_type && identifier_object_type != 'CollectingEvent') || (identifier_object && !identifier_object.kind_of?(CollectingEvent))
  end

end
