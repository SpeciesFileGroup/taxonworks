# The Identifier that identifies a collection object. Examples include barcodes printed on labels.
#
# Does *not* imply an accessioning process.
#
# @TODO Validate scope to CollectionObject
#
class Identifier::Local::CatalogNumber < Identifier::Local

  include Shared::DwcOccurrenceHooks

  def dwc_occurrences
    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins("JOIN identifiers i on i.identifier_object_id = co.id AND i.identifier_object_type = 'CollectionObject'")
      .where(i: {id:})
      .distinct
  end

end
