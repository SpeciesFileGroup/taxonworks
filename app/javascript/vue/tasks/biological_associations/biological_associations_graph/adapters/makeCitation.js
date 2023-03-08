export function makeCitation(citation) {
  return {
    id: citation.id,
    objectType: citation.citation_object_type,
    objectId: citation.citation_object_id,
    pages: citation.pages,
    sourceId: citation.source_id,
    label: citation.object_label
  }
}
