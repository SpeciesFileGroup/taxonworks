export function makeCitationPayload(c) {
  return {
    citation_object_id: c.objectId,
    citation_object_type: c.objectType,
    source_id: c.sourceId,
    pages: c.pages
  }
}
