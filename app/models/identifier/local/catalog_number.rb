# The Identifier that identifies a collection object. Examples include barcodes printed on labels.
#
# Does *not* imply an accessioning process.
#
# @TODO Validate scope to CollectionObject
#
class Identifier::Local::CatalogNumber < Identifier::Local

  include Shared::DwcOccurrenceHooks

  TARGETS = %w{CollectionObject Container Extract}

  validate :assigned_to_valid_object

  def dwc_occurrences

    # TODO: CONTAINERS UNION

    DwcOccurrence
      .joins("JOIN collection_objects co on dwc_occurrence_object_id = co.id AND dwc_occurrence_object_type = 'CollectionObject'")
      .joins("JOIN identifiers i on i.identifier_object_id = co.id AND i.identifier_object_type = 'CollectionObject'")
      .where(i: {id:})
      .distinct
  end

  private

  def assigned_to_valid_object
    # TODO: unkludge
    if (identifier_object_type && !(TARGETS.include?(identifier_object_type))) || ( identifier_object && !identifier_object.kind_of?(CollectionObject) && !identifier_object.kind_of?(Container) && !identifier_object.kind_of?(Extract)  )
      errors.add(:identifier_object_type, "only assignable to #{TARGETS.join(', ')}")
    end
  end

end
