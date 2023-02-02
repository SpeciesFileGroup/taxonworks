function parseRank(rank) {
  return Array.isArray(rank) ? rank.filter(Boolean).join(' ') : rank
}

export function listParser(list) {
  list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    otu_taxonomy_order: parseRank(item?.taxonomy?.order),
    otu_taxonomy_family: parseRank(item?.taxonomy?.family),
    otu_taxonomy_genus: parseRank(item?.taxonomy?.genus),
    otu: item.object_tag
  }))
}
