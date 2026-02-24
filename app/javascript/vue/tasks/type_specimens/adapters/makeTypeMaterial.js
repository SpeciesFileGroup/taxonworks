export function makeCollectionObject(data = {}) {
  return {
    id: data.id,
    globalId: data.global_id,
    total: data.total || 1,
    preparationTypeId: data.preparation_type_id,
    repositoryId: data.repository_id,
    collectingEventId: data.collecting_event_id,
    bufferedCollectingEvent: data.buffered_collecting_event,
    bufferedDeterminations: data.buffered_determinations,
    bufferedOtherLabels: data.buffered_other_labels
  }
}

export function makeTypeMaterial(data = {}) {
  return {
    id: data.id,
    globalId: data.global_id,
    protonymId: data.protonym_id,
    collectionObjectId: data.collection_object_id,
    type: data.type_type,
    label: data.object_tag,
    collectionObject: makeCollectionObject(data.collection_object),
    citation: {
      id: data.origin_citation?.id,
      globalId: data.origin_citation?.global_id,
      pages: data.origin_citation?.pages,
      source_id: data.origin_citation?.source?.id,
      label: data.origin_citation?.object_tag
    },
    isUnsaved: false
  }
}
