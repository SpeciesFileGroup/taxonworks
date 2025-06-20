function parseRank(rank) {
  return Array.isArray(rank) ? rank.filter(Boolean).join(' ') : rank
}

export function listParser(result) {
  const withoutObjectRadial = ['BiologicalAssociation',
    'BiologicalAssociationsGraph', 'Conveyance', 'Depiction', 'Observation']

  return result.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    objectGlobalId: withoutObjectRadial.includes(item.asserted_distribution_object_type) ? null : item.asserted_distribution_object.global_id,
    object_object_tag: item.asserted_distribution_object.object_tag,
    object_type: item.asserted_distribution_object_type,
    asserted_distribution_shape: item.asserted_distribution_shape.name,
    data_origin: item.asserted_distribution_shape.data_origin,
    citations: item?.citations?.map((c) => c.citation_source_body).join('; ')
  }))
}
