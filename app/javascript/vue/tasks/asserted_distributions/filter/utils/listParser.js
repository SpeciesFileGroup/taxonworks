function parseRank(rank) {
  return Array.isArray(rank) ? rank.filter(Boolean).join(' ') : rank
}

export function listParser(result) {
  return result.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    otu_taxonomy_order: parseRank(item.taxonomy?.order),
    otu_taxonomy_family: parseRank(item.taxonomy?.family),
    otu_taxonomy_genus: parseRank(item.taxonomy?.genus),
    otu_object_tag: item.otu.object_tag,
    geographic_area: item.geographic_area.name,
    data_origin: item.geographic_area.data_origin,
    citations: item?.citations?.map((c) => c.citation_source_body).join('; ')
  }))
}
