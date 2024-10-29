# The Identifier that identifies a collection object as recorded by the collector, typically in the field. 1:1 with dwc:recordNumber. Typically used in Botany
#
# Does *not* imply an accessioning process.
#
# @TODO Validate scope to CollectionObject
#
class Identifier::Local::RecordNumber < Identifier::Local

  include Shared::DwcOccurrenceHooks

  # skip_callback :validation, :before, :identifier_uniqueness

  validate :assigned_to_collection_object

  def dwc_occurrences
    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins("JOIN identifiers i on i.identifier_object_id = co.id AND i.identifier_object_type = 'CollectionObject'")
      .where(i: {id:})
      .distinct
  end

  private

  def assigned_to_collection_object
    errors.add(:identifier_object_type, 'only assignable to CollectionObject') if (identifier_object_type && identifier_object_type != 'CollectionObject') || (identifier_object && !identifier_object.kind_of?(CollectionObject))
  end


end
