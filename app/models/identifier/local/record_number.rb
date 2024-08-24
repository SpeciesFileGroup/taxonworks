# The Identifier that identifies a collection object as recorded by the collector, typically in the field. 1:1 with dwc:recordNumber. Typically used in Botany
#
# Does *not* imply an accessioning process.
#
# @TODO Validate scope to CollectionObject
#
class Identifier::Local::RecordNumber < Identifier::Local

  include Shared::DwcOccurrenceHooks

  def dwc_occurrences
    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins("JOIN identifiers i on i.identifier_object_id = co.id AND i.identifier_object_type = 'CollectionObject'")
      .where(i: {id:})
      .distinct
  end

end
