export function makeCitation(data) {
  return {
    id: data.id,
    label: data.object_label || data.label,
    objectId: data.citation_object_id,
    objectType: data.citation_object_type || data.objectType,
    objectUuid: data.objectUuid,
    pages: data.pages,
    sourceId: data.source_id,
    uuid: crypto.randomUUID()
  }
}
