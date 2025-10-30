export function makeTaxonNode(taxon) {
  return {
    id: taxon.id,
    name: [taxon.cached_html, taxon.cached_author_year].join(' '),
    parentId: taxon.parent_id,
    isValid: taxon.cached_is_valid,
    children: []
  }
}
