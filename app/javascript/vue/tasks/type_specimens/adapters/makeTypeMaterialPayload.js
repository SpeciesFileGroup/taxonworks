function makeCollectionObjectPayload(collectionObject = {}) {
  return {
    id: collectionObject.id,
    total: collectionObject.total,
    preparation_type_id: collectionObject.preparationTypeId,
    repository_id: collectionObject.repositoryId,
    collecting_event_id: collectionObject.collectingEventId,
    buffered_collecting_event: collectionObject.bufferedCollectingEvent,
    buffered_determinations: collectionObject.bufferedDeterminations,
    buffered_other_labels: collectionObject.bufferedOtherLabels
  }
}

export function makeTypeMaterialPayload(typeMaterial = {}) {
  return {
    id: typeMaterial.id,
    protonym_id: typeMaterial.protonymId,
    collection_object_id: typeMaterial.collectionObjectId,
    type_type: typeMaterial.type,
    collection_object_attributes: makeCollectionObjectPayload(
      typeMaterial.collectionObject
    ),
    origin_citation_attributes: typeMaterial.citation
      ? {
          id: typeMaterial.citation.id,
          pages: typeMaterial.citation.pages,
          source_id: typeMaterial.citation.source_id,
          _destroy:
            (!typeMaterial.citation.source_id && typeMaterial.citation.id) ||
            undefined
        }
      : null
  }
}
