module Queries::Concerns::Sounds
  extend ActiveSupport::Concern

  def otus_from_sound_query
    return nil if sound_query.nil?

    s = sound_query.all

    queries = [
      ::Otu
        .with(query_sounds: s)
        .joins(:conveyances)
        .joins('JOIN query_sounds on conveyances.sound_id = query_sounds.id'),
      ::Otu
        .with(query_sounds: s)
        .joins(collection_objects: :conveyances)
        .joins('JOIN query_sounds on conveyances.sound_id = query_sounds.id'),
      ::Otu
        .with(query_sounds: s)
        .joins(field_occurrences: :conveyances)
        .joins('JOIN query_sounds on conveyances.sound_id = query_sounds.id'),
      ::Otu
        .with(query_sounds: s)
        .joins(collecting_events: :conveyances)
        .joins('JOIN query_sounds on conveyances.sound_id = query_sounds.id'),
      ::Otu
        .with(query_sounds: s)
        .joins(:origin_relationships)
        .joins("JOIN query_sounds on origin_relationships.new_object_id = query_sounds.id AND origin_relationships.new_object_type = 'Sound'"),
      ::Otu
        .with(query_sounds: s)
        .joins(:anatomical_parts)
        .joins("JOIN origin_relationships ON origin_relationships.old_object_id = anatomical_parts.id AND origin_relationships.old_object_type = 'AnatomicalPart' AND origin_relationships.new_object_type = 'Sound'")
        .joins('JOIN query_sounds on origin_relationships.new_object_id = query_sounds.id'),
      ::Otu
        .with(query_sounds: s)
        .joins(:collection_objects)
        .joins("JOIN origin_relationships ON origin_relationships.old_object_id = collection_objects.id AND origin_relationships.old_object_type IN ('CollectionObject', 'Specimen', 'Lot', 'RangedLot') AND origin_relationships.new_object_type = 'Sound'")
        .joins('JOIN query_sounds on origin_relationships.new_object_id = query_sounds.id'),
      ::Otu
        .with(query_sounds: s)
        .joins(:field_occurrences)
        .joins("JOIN origin_relationships ON origin_relationships.old_object_id = field_occurrences.id AND origin_relationships.old_object_type = 'FieldOccurrence' AND origin_relationships.new_object_type = 'Sound'")
        .joins('JOIN query_sounds on origin_relationships.new_object_id = query_sounds.id'),
      ::Otu
        .with(query_sounds: s)
        .joins(:collecting_events)
        .joins("JOIN origin_relationships ON origin_relationships.old_object_id = collecting_events.id AND origin_relationships.old_object_type = 'CollectingEvent' AND origin_relationships.new_object_type = 'Sound'")
        .joins('JOIN query_sounds on origin_relationships.new_object_id = query_sounds.id')
    ]

    ::Queries.union(::Otu, queries)
  end
end
