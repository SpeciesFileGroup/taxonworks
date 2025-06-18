function parseRank(rank) {
  return Array.isArray(rank) ? rank.filter(Boolean).join(' ') : rank
}

export function listParser(result) {
  return result.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    objectGlobalId: item.asserted_distribution_object_type == 'BiologicalAssociation' ? null : item.asserted_distribution_object.global_id,
    object_object_tag: item.asserted_distribution_object.object_tag,
    object_type: item.asserted_distribution_object_type,
    asserted_distribution_shape: item.asserted_distribution_shape.name,
    data_origin: item.asserted_distribution_shape.data_origin,
    citations: item?.citations?.map((c) => c.citation_source_body).join('; ')
  }))
}
