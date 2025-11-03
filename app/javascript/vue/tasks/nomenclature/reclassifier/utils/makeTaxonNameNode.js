export function makeTaxonNode(taxon) {
  return {
    id: taxon.id,
    name:
      taxon.label ?? [taxon.cached_html, taxon.cached_author_year].join(' '),
    parentId: taxon.parent_id,
    isValid: taxon.cached_is_valid ?? taxon.is_valid,
    leaf: taxon.leaf_node,
    children: []
  }
}
